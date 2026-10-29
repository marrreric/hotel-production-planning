package ru.etu.hotel.model.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class BomModReplaceRequest {
    private Integer baseComponentId;
    private Integer newComponentId;
    private BigDecimal quantity;
    private Integer eiId;
    private Integer changeId;
}