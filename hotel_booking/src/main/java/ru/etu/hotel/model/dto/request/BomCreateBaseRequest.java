package ru.etu.hotel.model.dto.request;

import lombok.Data;

@Data
public class BomCreateBaseRequest {
    private Integer productId;
    private String designation;
    private String description;
}