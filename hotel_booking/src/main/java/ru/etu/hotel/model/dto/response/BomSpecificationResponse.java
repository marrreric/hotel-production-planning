package ru.etu.hotel.model.dto.response;

import lombok.Builder;
import lombok.Data;

@Data @Builder
public class BomSpecificationResponse {
    private Integer id;
    private Integer productId;
    private String productName;
    private String designation;
    private String specType;
    private Integer baseSpecId;
    private String status;
    private String description;
}