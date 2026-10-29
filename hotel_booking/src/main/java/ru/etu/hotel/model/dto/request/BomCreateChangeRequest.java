package ru.etu.hotel.model.dto.request;

import lombok.Data;
import java.time.LocalDate;

@Data
public class BomCreateChangeRequest {
    private String number;
    private LocalDate date;
    private String description;
}