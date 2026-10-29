package ru.etu.hotel.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "specification_line")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class BomSpecificationLine {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "spec_id", nullable = false)
    private Integer specId;

    @Column(name = "position", nullable = false)
    private Integer position;

    @Column(name = "action", length = 20, nullable = false)
    private String action;

    @Column(name = "excluded_component_id")
    private Integer excludedComponentId;

    @Column(name = "component_id")
    private Integer componentId;

    @Column(name = "quantity")
    private BigDecimal quantity;

    @Column(name = "ei_id")
    private Integer eiId;

    @Column(name = "date_from", nullable = false)
    private LocalDate dateFrom;

    @Column(name = "date_to")
    private LocalDate dateTo;

    @Column(name = "notice_from_id")
    private Integer noticeFromId;

    @Column(name = "notice_to_id")
    private Integer noticeToId;
}