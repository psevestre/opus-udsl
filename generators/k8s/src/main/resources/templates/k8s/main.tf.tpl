/*
 * Defini��es do ambiente
 *
 * ARQUIVO GERADO AUTOMATICAMENTE: N�O EDITAR !!!
 */
<%
def dollar = '$'
%> 
  
 
//================================================================== Ingress
<% env.endpoints.each { ep -> %>
module "ingress_${tf.moduleName(ep.name)}" {
 	source = "./ingress/${ep.name}"
	
<% if ( config?.security?.enabled?: false ) { %>
	keycloak_host = var.keycloak_host
<% } %>
	 
} 
  
<% } %>

//================================================================== Externals Endpoints
<% env.externalEndpoints.each { ep -> %>

// Endpoint: ${ep.name}
variable "external_${tf.moduleName(ep.name)}_target" {
    type = string
    description = "Endere�o f�sico do servi�o externo ${ep.name}"
    default = "${ep.target}" 
}

module "external_${tf.moduleName(ep.name)}" {
    source = "./external/${ep.name}"
    target_address = var.external_${tf.moduleName(ep.name)}_target
}

<% } %> 

 
//================================================================== Deployments
 
<% env.deployments.each { dep -> %>
module "${tf.moduleName(dep.name)}" {
  source = "./${dep.name}"
} 
<% } %>

<% if (!env.messageChannels.empty) { %>

//================================================================== Messaging

<%
def messaging_provider = config?.messaging?.provider?:'rabbitmq'
%>

variable "management_endpoint" {
	type = string
	description = "Endpoint para configura��o do sistema de mensageria. Utilizar quando o TF n�o tiver acesso direto ao servidor"
	default = ""
}

<% if ( "rabbitmq" == messaging_provider ) { %>
	variable "rabbitmq_management_username" {
		type = string
		description = "Usu�rio administrativo para o RabbitMQ"
		default = "admin"
	}
	
	variable "rabbitmq_management_password" {
		type = string
		description = "Senha do usu�rio administrativo do RabbitMQ"
		default = "admin"
	}
	
<% } %>
	

<%  if ( config.messaging.external ) { %>
	variable "message_broker_address" {
		type = string
		description = "Hostname do servidor de mensageria externo a ser utilizado"
		default = "broker.example.com"
	}
<% } %>
	
module "messaging" {
	source = "./messaging/${messaging_provider}"
<% if ( "rabbitmq" == messaging_provider ) { %>
	rabbitmq_management_endpoint = var.management_endpoint
	rabbitmq_management_username = var.rabbitmq_management_username
	rabbitmq_management_password = var.rabbitmq_management_password	
<% } %>

<% if ( config.messaging.external ) { %>
	message_broker_address = var.message_broker_address
<% } %>	
}

<% } /* if env.messageChannels.empty */ %>

<% if ( config?.security?.enabled?: false ) { %>
	
<% if ( config?.security?.enabled?: false ) { %>
//================================================================== Security
	
variable "keycloak_host" {
	type = string
	description = "Hostname para acesso ao keycloak"
	default = "keycloak.127.0.0.1.xip.io"
}
			
<% } %>
		
<% def security_provider = config?.security?.provider?: 'keycloak' %>

module "security" {
	source = "./security/${security_provider}"	
}

<% } %>


