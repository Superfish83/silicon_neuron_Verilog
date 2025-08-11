## Team 흰뺨검둥오리

> 최초작성일 2025-08-04
> 최종개정일 2025-08-12
> 참여자 강명석, 김연준, 임준서

2025년 시행 `전국 대학생 AI 반도체 설계 경진대회`의 1차 과제

## 코드 구조

- `/software_test/`: Neuron model 근사 결과, Python simulation 결과와 Verilog simulation 출력을 비교, plotting하는 코드
- `/src/`: Verilog 소스 코드
- `/src/IZH_*.v`: Izhikevich Model 기반 디지털 뉴런의 구현과 관련된 모듈
- `/src/synapse.v`: synaptic weight를 저장하는 SRAM 모듈
- `/src/accumulator.v`: synaptic weight를 합해 synaptic input을 구하는 모듈
