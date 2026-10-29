package ru.etu.hotel.model.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class BomAddLineRequest {
    private Integer componentId;
    private BigDecimal quantity;
    private Integer eiId;
    private Integer changeId;
    private Integer position;
}