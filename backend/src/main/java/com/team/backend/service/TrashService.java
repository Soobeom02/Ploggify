package com.team.backend.service;

import com.team.backend.dto.TrashData;
import org.springframework.stereotype.Service;

@Service
public class TrashService {
    public TrashData echoData(TrashData data) {
        // 나중에 여기서 모델 호출, 계산, 저장 로직 추가 가능
        return data;
    }
}
