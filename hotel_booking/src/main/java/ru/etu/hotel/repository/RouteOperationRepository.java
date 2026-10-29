package ru.etu.hotel.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import ru.etu.hotel.model.entity.RouteOperation;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface RouteOperationRepository extends JpaRepository<RouteOperation, Integer> {

    List<RouteOperation> findByProductIdOrderByNumAsc(Integer productId);

    @Query(value = "SELECT * FROM find_tm(:productId)", nativeQuery = true)
    List<Object[]> findTm(@Param("productId") Integer productId);

    @Query(value = "SELECT * FROM mr_q(:opId, :quantity)", nativeQuery = true)
    List<Object[]> mrQ(@Param("opId") Integer opId,
                       @Param("quantity") Double quantity);

    @Query(value = "SELECT * FROM sum_mr(:productId, :quantity)", nativeQuery = true)
    List<Object[]> sumMr(@Param("productId") Integer productId,
                         @Param("quantity") Double quantity);

    @Query(value = "SELECT * FROM tr_to(:productId, :quantity)", nativeQuery = true)
    List<Object[]> trTo(@Param("productId") Integer productId,
                        @Param("quantity") Double quantity);

    @Query(value = "SELECT * FROM calc_cost(:productId, :quantity)", nativeQuery = true)
    List<Object[]> calcCost(@Param("productId") Integer productId,
                            @Param("quantity") Double quantity);

    @Modifying
    @Query(value = "INSERT INTO product_tp_value(product_id, param_id, value) " +
                   "VALUES (:productId, :paramId, :value) " +
                   "ON CONFLICT (product_id, param_id) DO UPDATE SET value = EXCLUDED.value",
           nativeQuery = true)
    int setTpValue(@Param("productId") Integer productId,
                   @Param("paramId") Integer paramId,
                   @Param("value") BigDecimal value);

    @Query(value = "SELECT apply_typical_process(:productId, :tpId)", nativeQuery = true)
    Integer applyTypicalProcess(@Param("productId") Integer productId,
                                @Param("tpId") Integer tpId);
}
