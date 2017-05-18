package cn.home1.oss.lib.security.internal.zuul;

import static cn.home1.oss.boot.autoconfigure.AppSecurity.ENABLED;
import static cn.home1.oss.lib.security.api.GenericUser.GENERIC_USER_TOKEN;

import cn.home1.oss.boot.autoconfigure.ConditionalOnAppSecurity;
import cn.home1.oss.lib.security.api.GenericUser;
import cn.home1.oss.lib.security.starter.WebApplicationSecurityAutoConfiguration;
import cn.home1.oss.lib.webmvc.api.TypeSafeToken;

import com.netflix.zuul.ZuulFilter;

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
@ConditionalOnClass({HasFeatures.class, NamedContextFactory.class, ZuulFilter.class})
@Configuration
public class ZuulTokenConfiguration {

  @Qualifier(GENERIC_USER_TOKEN)
  @Autowired
  private TypeSafeToken<GenericUser> genericUserToken;

  @Bean
  public ContextAuthTokenZuulFilter contextAuthTokenZuulFilter() {
    final ContextAuthTokenZuulFilter filter = new ContextAuthTokenZuulFilter();
    filter.setToken(this.genericUserToken);
    return filter;
  }
}
