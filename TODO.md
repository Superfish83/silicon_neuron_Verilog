## SRAM

TODO: `CS`, `WE`, `OE` 신호로 제어 방식 변경하기. 현재는 we만 사용.

## System verilog

- `reg` 대신 `logic` 사용하기
    - SystemVerilog에서는 `logic`이라는게 `wire`와 `reg`를 대체함.
    - `always` 블록으로 reg를 쓸지 wire를 쓸지 알아서 판단해줌.
    - 단, data bus와 같이 동일한 망을 사용해야 하는 경우에는 `wire`를 사용해야 함.

- interface 사용하기
    - `interface`를 사용하면 여러 신호를 하나의 묶음으로 관리할 수 있음.
    - 예를 들어, `clk`, `reset`, `data` 등을 하나의 인터페이스로 묶어서 사용할 수 있음.
    - 현재 databus를 묶어놨음.
    - TODO: Sram에 interface 적용하기.
 

## Compilation Errors

TODO: FIX
```text
IZH_neuron.sv:33
Unknown module type: impulse_generator
8 error(s) during elaboration.
*** These modules were missing:
        impulse_generator referenced 1 times.
***
```

현재 icarus에서 sv가 완전히 지원이 안되는 것 같음. Cadence에서 확인 필요.
compile error가 해결이 안되면 verilog2012에서 내가 짠 것처럼 interfacer가 안 되는 거일 수도 있음.
그러할 경우, interface를 사용하지 않고, 각 모듈에서 직접 신호를 연결해야 함.

## Check me out

- 내가 이해한게 맞으면, j인덱스에서 spike가 발생하면 j인덱스에 해당하는 뉴런들만 업데이트 하고 계속 진행하는 방식.
- 전달받은 그림에서는 neuron을 버스에서 읽어올때 동시 rw가 불가능한 것처럼 적혀있어서 일단 동일하게 구현함.
- 도표에서 어디가 MSB인지 모르겠어서 가장 오른쪽을 MSB로 생각하고 구현함.
- nram에서 w값 어디에 쓰이나요? register일부 대체하는 거면 그런 IZH_neuron 대신 새로 구현해야하는 건가