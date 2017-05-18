package cn.home1.oss.lib.security.internal.feign;

import static cn.home1.oss.boot.autoconfigure.AppSecurity.ENABLED;
import static cn.home1.oss.lib.security.api.GenericUser.GENERIC_USER_TOKEN;

import cn.home1.oss.boot.autoconfigure.ConditionalOnAppSecurity;
import cn.home1.oss.lib.security.api.GenericUser;
import cn.home1.oss.lib.security.starter.WebApplicationSecurityAutoConfiguration;
import cn.home1.oss.lib.webmvc.api.TypeSafeToken;

import feign.Feign;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.AutoConfigureAfter;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.cloud.client.actuator.HasFeatures;
import org.springframework.cloud.context.named.NamedContextFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Created by zhanghaolun on 16/11/22.
 */
@AutoConfigureAfter({WebApplicationSecurityAutoConfiguration.class})
@ConditionalOnAppSecurity(ENABLED)
@ConditionalOnClass({HasFeatures.class, NamedContextFactory.class, Feign.class})
@Configuration
public class FeignTokenConfiguration {

  @Qualifier(GENERIC_USER_TOKEN)
  @Autowired
  private TypeSafeToken<GenericUser> genericUserToken;

  @Bean
  public ContextAuthTokenFeignRequestInterceptor contextAuthTokenFeignRequestInterceptor() {
    final ContextAuthTokenFeignRequestInterceptor interceptor = new ContextAuthTokenFeignRequestInterceptor();
    interceptor.setToken(this.genericUserToken);
    return interceptor;
  }
}
