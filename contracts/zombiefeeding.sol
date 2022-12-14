pragma solidity ^0.4.19;

import "./zombiefactory.sol";

contract KittyInterface { //인터페이스 선언 - 컨트랙트 선언 형태, 내부의 함수는 중괄호(몸통)부분 없이 선언
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}


contract ZombieFeeding is ZombieFactory {
    
    KittyInterface kittyContract;

    function setKittyContractAddress(address _address) external onlyOwner{
    kittyContract = KittyInterface(_address);
  }

  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }
 
  function _isReady(Zombie storage _zombie) internal view returns (bool) {
      return (_zombie.readyTime <= now);
  }


    function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) internal {
    require(msg.sender == zombieToOwner[_zombieId]); //좀비의 주인인지 확인
    Zombie storage myZombie = zombies[_zombieId];
    require(_isReady(myZombie));
     _targetDna = _targetDna % dnaModulus; //targetDNA를 16자리로 맞춰주고
    uint newDna = (myZombie.dna + _targetDna) / 2; //원래 좀비와 타겟의 DNA 평균을 내서 새로운 DNA로
    if(keccak256(_species) == keccak256("kitty")) { //고양이가 먹이일 경우
        newDna = newDna - newDna % 100 + 99;        //마지막 두 자리 99로 변경
    }
    _createZombie("NoName", newDna); //새로운 좀비 생성
    _triggerCooldown(myZombie);
    
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public { //고양이를 먹이로 주는 함수
      uint kittyDna;
      (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId); //위에서 인터페이스 사용한 kittyContract의 getKitty함수 호출
      feedAndMultiply(_zombieId, kittyDna,"kitty");
  }
}
//Storage는 블록체인 상에 영구적으로 저장되는 변수, Memory는 임시적으로 저장되는 변수
//상태 변수(함수 외부에 선언된 변수)는 초기 설정상 storage로 선언되어 블록체인에 영구적으로 저장되는 반면, 함수 내에 선언된 변수는 memory로 자동 선언
//internal은 함수가 정의된 컨트랙트를 상속하는 컨트랙트에서도 접근이 가능
//external은 함수가 컨트랙트 바깥에서만 호출될 수 있고 컨트랙트 내의 다른 함수에 의해 호출될 수 없다
//블록체인 상에 있으면서 우리가 소유하지 않은 컨트랙트와 우리 컨트랙트가 상호작용을 하려면 우선 인터페이스를 정의
//인터페이스를 정의하는 방법이 컨트랙트를 정의하는 것과 유사 
//다른 컨트랙트와 상호작용하고자 하는 함수만을 선언할 뿐 다른 함수나 상태 변수를 언급하지 않음.
//다음으로, 함수 몸체를 정의하지 않지. 중괄호 {, }를 쓰지 않고 함수 선언을 세미콜론(;)으로 간단하게 끝내지

//chapter 3
//컨트랙트로 배포한 최초의 코드는 항상 블록체인에 영구적으로 존재
//Constructor :  컨트랙트와 동일한 이름을 가진,생략할 수 있는 특별한 함수
//Modifier : 함수들에 대한 접근을 제어하기 위해 사용되는 일종의 유사 함수. 함수 실행 전의 요구사항 충족 여부를 확인하는 데에 사용
//구조체 내에서는 uint타입을 작은 것으로 설정시 GAS 소모를 줄일 수 있음. +같은 크기로 설정시 더 줄일 수 있음