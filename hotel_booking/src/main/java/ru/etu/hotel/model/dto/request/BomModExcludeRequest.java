package ru.etu.hotel.model.dto.request;

import lombok.Data;

@Data
public class BomModExcludeRequest {
    private Integer baseComponentId;
    private Integer changeId;
}