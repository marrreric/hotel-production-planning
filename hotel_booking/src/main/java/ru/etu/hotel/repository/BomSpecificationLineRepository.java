package ru.etu.hotel.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import ru.etu.hotel.model.entity.BomSpecificationLine;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface BomSpecificationLineRepository extends JpaRepository<BomSpecificationLine, Integer> {

    @Query(value = "SELECT * FROM bom_lines(:specId, :onDate)", nativeQuery = true)
    List<Object[]> findLinesOnDate(@Param("specId") Integer specId,
                                   @Param("onDate") LocalDate onDate);

    @Query(value = "SELECT * FROM bom_explode(:specId, :onDate)", nativeQuery = true)
    List<Object[]> explode(@Param("specId") Integer specId,
                           @Param("onDate") LocalDate onDate);

    @Query(value = "SELECT * FROM bom_sum_norms(:productId, :classId, :onDate, :specId)", nativeQuery = true)
    List<Object[]> sumNorms(@Param("productId") Integer productId,
                            @Param("classId") Integer classId,
                            @Param("onDate") LocalDate onDate,
                            @Param("specId") Integer specId);

    @Query(value = "SELECT * FROM bom_where_used(:componentId, :onDate)", nativeQuery = true)
    List<Object[]> whereUsed(@Param("componentId") Integer componentId,
                             @Param("onDate") LocalDate onDate);

    @Query(value = "SELECT bom_add_line(:specId, :componentId, :qty, :eiId, :changeId, :position)", nativeQuery = true)
    Integer addLine(@Param("specId") Integer specId,
                    @Param("componentId") Integer componentId,
                    @Param("qty") BigDecimal qty,
                    @Param("eiId") Integer eiId,
                    @Param("changeId") Integer changeId,
                    @Param("position") Integer position);

    @Query(value = "SELECT bom_change_qty(:lineId, :newQty, :changeId)", nativeQuery = true)
    Integer changeQty(@Param("lineId") Integer lineId,
                      @Param("newQty") BigDecimal newQty,
                      @Param("changeId") Integer changeId);

    @Query(value = "SELECT bom_close_line(:lineId, :changeId)", nativeQuery = true)
    void closeLine(@Param("lineId") Integer lineId,
                   @Param("changeId") Integer changeId);

    @Query(value = "SELECT bom_replace_component(:lineId, :newComponent, :newQty, :changeId)", nativeQuery = true)
    Integer replaceComponent(@Param("lineId") Integer lineId,
                             @Param("newComponent") Integer newComponent,
                             @Param("newQty") BigDecimal newQty,
                             @Param("changeId") Integer changeId);

    @Query(value = "SELECT bom_mod_exclude(:modSpecId, :baseComponent, :changeId)", nativeQuery = true)
    Integer modExclude(@Param("modSpecId") Integer modSpecId,
                       @Param("baseComponent") Integer baseComponent,
                       @Param("changeId") Integer changeId);

    @Query(value = "SELECT bom_mod_replace(:modSpecId, :baseComponent, :newComponent, :qty, :eiId, :changeId)", nativeQuery = true)
    Integer modReplace(@Param("modSpecId") Integer modSpecId,
                       @Param("baseComponent") Integer baseComponent,
                       @Param("newComponent") Integer newComponent,
                       @Param("qty") BigDecimal qty,
                       @Param("eiId") Integer eiId,
                       @Param("changeId") Integer changeId);
                       @org.springframework.data.jpa.repository.Query(
    value = "SELECT * FROM bom_sum_norms_for_qty(:productId, :classId, :quantity, :onDate, :specId)",
    nativeQuery = true)
List<Object[]> sumNormsForQty(
    @org.springframework.data.repository.query.Param("productId") Integer productId,
    @org.springframework.data.repository.query.Param("classId") Integer classId,
    @org.springframework.data.repository.query.Param("quantity") java.math.BigDecimal quantity,
    @org.springframework.data.repository.query.Param("onDate") java.time.LocalDate onDate,
    @org.springframework.data.repository.query.Param("specId") Integer specId);
}