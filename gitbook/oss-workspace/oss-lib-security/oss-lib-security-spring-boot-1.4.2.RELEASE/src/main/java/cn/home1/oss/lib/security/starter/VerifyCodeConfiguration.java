package cn.home1.oss.lib.security.starter;

import static cn.home1.oss.boot.autoconfigure.AppSecurityProperties.APP_SECURITY;
import static cn.home1.oss.boot.autoconfigure.AppType.MIXED;
import static cn.home1.oss.boot.autoconfigure.AppType.RESTFUL;
import static cn.home1.oss.boot.autoconfigure.AppType.TEMPLATE;
import static org.springframework.boot.autoconfigure.security.SecurityProperties.DEFAULT_FILTER_ORDER;

import cn.home1.oss.boot.autoconfigure.AppProperties;
import cn.home1.oss.boot.autoconfigure.AppSecurity;
import cn.home1.oss.boot.autoconfigure.ConditionalOnAppSecurity;
import cn.home1.oss.boot.autoconfigure.ConditionalOnAppType;
import cn.home1.oss.lib.security.internal.VerifyCodeFilter;
import cn.home1.oss.lib.security.internal.preauth.PreAuthTokenFilter;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;

/**
 * Created by zhanghaolun on 16/8/19.
 */

@ConditionalOnAppSecurity(AppSecurity.ENABLED)
@ConditionalOnAppType({MIXED, RESTFUL, TEMPLATE})
@Configuration
@Order(VerifyCodeConfiguration.ORDER_VERIFY_CODE)
public class VerifyCodeConfiguration extends SecurityConfigurerAdapter<VerifyCodeConfiguration> {

  public static final int ORDER_VERIFY_CODE = DEFAULT_FILTER_ORDER + 1;

  @Autowired
  private AppProperties appProperties;

  @Override
  public void configure(final HttpSecurity http) {
    if (this.appProperties.getSecurity().getVerifyCode()) {
      http.addFilterAfter(this.verifyCodeFilter(), PreAuthTokenFilter.class);
    }
  }

  @Bean
  @ConditionalOnProperty(prefix = APP_SECURITY, name = "verifyCode", havingValue = "true")
  public VerifyCodeFilter verifyCodeFilter() { // TODO is filter bean ok, twice?
    return new VerifyCodeFilter();
  }
}
