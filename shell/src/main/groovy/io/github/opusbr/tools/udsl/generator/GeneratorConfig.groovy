package io.github.opusbr.tools.udsl.generator

import org.springframework.stereotype.Component

/**
 * Configuração global utilizada pelo gerador
 * @author Philippe
 *
 */
@Component
class GeneratorConfig {
	
	File customTemplatesDir;
	
	public GeneratorConfig() {}
	
}
