package ru.etu.hotel.model.dto.response;

import lombok.Builder;
import lombok.Data;

@Data @Builder
public class BomWhereUsedResponse {
    private Integer level;
    private Integer productId;
    private String productName;
}