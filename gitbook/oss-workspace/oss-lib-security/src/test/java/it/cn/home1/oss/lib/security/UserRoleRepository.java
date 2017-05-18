package it.cn.home1.oss.lib.security;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRoleRepository extends PagingAndSortingRepository<UserRole, String> {
  // ,QueryDslPredicateExecutor<UserRole>

}
