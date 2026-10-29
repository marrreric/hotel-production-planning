package ru.etu.hotel.model.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "unit_of_measure")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class UnitOfMeasure {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "code", length = 16, nullable = false, unique = true)
    private String code;

    @Column(name = "name", length = 64, nullable = false)
    private String name;

    @Column(name = "short_name", length = 16, nullable = false)
    private String shortName;

    @Column(name = "sort_order")
    private Integer sortOrder;
}