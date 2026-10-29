package ru.etu.hotel.model.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "change_notice")
@Data @NoArgsConstructor @AllArgsConstructor @Builder
public class ChangeNotice {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "number", length = 50, nullable = false, unique = true)
    private String number;

    @Column(name = "date", nullable = false)
    private LocalDate date;

    @Column(name = "description")
    private String description;

    @Column(name = "status", length = 20, nullable = false)
    private String status;
}