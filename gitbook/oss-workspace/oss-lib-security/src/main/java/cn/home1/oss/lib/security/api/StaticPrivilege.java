package cn.home1.oss.lib.security.api;

import cn.home1.oss.lib.common.DiscoverableEnum;

import org.springframework.security.core.GrantedAuthority;

/**
 * User should define enum which implements this interface.
 * Created by zhanghaolun on 16/7/14.
 */
public interface StaticPrivilege<T extends Enum<T> & StaticPrivilege<T>>
    extends DiscoverableEnum<T>, GrantedAuthority {

  String PRIVILEGE_PREFIX = "PRIVILEGE_";

  static String toAuthority(final String resource, final String action) {
    return PRIVILEGE_PREFIX + resource + "_" + action;
  }

  String getAction();

  @Override
  default String getAuthority() {
    return toAuthority(getResource(), getAction());
  }

  String getResource();

  @Override
  default String getText() {
    return this.getAuthority();
  }
}
