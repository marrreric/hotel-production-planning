package ru.etu.hotel.model.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class BomReplaceComponentRequest {
    private Integer newComponentId;
    private BigDecimal quantity;
    private Integer changeId;
}