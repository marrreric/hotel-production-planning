package ru.etu.hotel.model.dto.request;

import lombok.Data;

@Data
public class BomCreateModificationRequest {
    private Integer productId;
    private Integer baseSpecId;
    private String designation;
    private String description;
}