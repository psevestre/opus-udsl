/**
 * 
 */
package br.com.opussoftware.udsl.model

import groovy.transform.Canonical

/**
 * @author Philippe
 *
 */
@Canonical
class EnvironmentSpec {
	
	String name;
	List<EndpointSpec> endpoints = []
	List<EndpointSpec> externalEndpoints = []
	List<DeploymentSpec> deployments = []
	List<MessageChannelSpec> messageChannels = []
	
	public Endpoint( String name, Closure spec) {
		def delegate = new EndpointSpec(name)
		spec.delegate = delegate
		spec.resolveStrategy = Closure.DELEGATE_FIRST
		spec.run()
		
		endpoints.add(delegate)		
	}
	
	/**
	 * Service Endpoint
	 * @param name
	 * @param target
	 * @param proto
	 * @return
	 */
	public Endpoint( Map params) {		
		def ep = new EndpointSpec(params)		
		externalEndpoints.add(ep)
	}
	
	public Deployment( String name, Closure spec) {
		def delegate = new DeploymentSpec(name)
		spec.delegate = delegate
		spec.resolveStrategy = Closure.DELEGATE_FIRST
		spec.run()
		
		deployments.add(delegate)

	}

	public MessageChannel( Map params ) {
		def delegate = new MessageChannelSpec(params)
		
		messageChannels.add(delegate)

	}

}
