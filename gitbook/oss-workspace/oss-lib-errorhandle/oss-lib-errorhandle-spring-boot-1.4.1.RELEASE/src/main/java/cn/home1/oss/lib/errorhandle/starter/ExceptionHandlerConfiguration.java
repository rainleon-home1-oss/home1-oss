package cn.home1.oss.lib.errorhandle.starter;

import cn.home1.oss.lib.errorhandle.internal.DefaultExceptionHandler;
import cn.home1.oss.lib.errorhandle.internal.RestfulExceptionHandler;
import cn.home1.oss.lib.errorhandle.internal.TemplateExceptionHandler;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.autoconfigure.web.ServerProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Created by zhanghaolun on 16/8/17.
 */
@Configuration
public class ExceptionHandlerConfiguration {

  @Autowired
  private ServerProperties serverProperties;

  /**
   * experimental.
   *
   * @return defaultExceptionHandler
   */
  @Bean
  @ConditionalOnProperty(prefix = "app.error", name = "handlerEnabled", havingValue = "true")
  public DefaultExceptionHandler defaultExceptionHandler() {
    return new DefaultExceptionHandler();
  }

  @Bean
  public RestfulExceptionHandler restfulExceptionHandler() {
    return new RestfulExceptionHandler();
  }

  @Bean
  public TemplateExceptionHandler templateExceptionHandler() {
    final TemplateExceptionHandler handler = new TemplateExceptionHandler();
    handler.setErrorPage(this.serverProperties.getError().getPath());
    return handler;
  }
}
