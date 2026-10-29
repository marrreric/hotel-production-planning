package ru.etu.hotel.model.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class BomChangeQtyRequest {
    private BigDecimal quantity;
    private Integer changeId;
}