package ru.etu.hotel.model.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

// Изделие-Операция (TM1): операция маршрута или позиция закупки
@Entity
@Table(name = "route_operation")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class RouteOperation {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "product_id", nullable = false)
    private Integer productId;

    @Column(name = "kind", length = 20, nullable = false)
    private String kind;

    @Column(name = "num")
    private Integer num;

    @Column(name = "name")
    private String name;

    @Column(name = "op_class_id")
    private Integer opClassId;

    @Column(name = "work_center_id")
    private Integer workCenterId;

    @Column(name = "profession_id")
    private Integer professionId;

    @Column(name = "qualification")
    private Integer qualification;

    @Column(name = "t_pz")
    private BigDecimal tpz;

    @Column(name = "t_sht")
    private BigDecimal tsht;

    @Column(name = "ei_id")
    private Integer eiId;

    @Column(name = "unit_price")
    private BigDecimal unitPrice;

    @Column(name = "tp_id")
    private Integer tpId;
}
