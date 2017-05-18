package cn.home1.oss.lib.hystrix.spring.config;

import com.netflix.hystrix.Hystrix;

import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

/**
 * Auto configuration for Hystrix.
 */
@Configuration
@ConditionalOnClass({Hystrix.class})
@ComponentScan(basePackages = "cn.home1.oss.lib.hystrix.config")
public class HystrixAutoConfiguration {
}
