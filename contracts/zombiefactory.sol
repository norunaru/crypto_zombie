pragma solidity ^0.4.19;

contract ZombieFactory {

    event NewZombie(uint zombieId, string name, uint dna); //id는 몇 번째 좀비인지를 알려주는 배열의 인덱스 번호

    uint dnaDigits = 16; //좀비의 DNA는 16자리 숫자
    //상태 변수는 컨트랙트 저장소에 영구적으로 저장
    uint dnaModulus = 10 ** dnaDigits; //모듈로 연산에 사용하여 16자리보다 큰 숫자를 16자리로 만들어줌

    struct Zombie { //좀비 구조체 선언 - 이름, DNA
        string name;
        uint dna;
    }

     Zombie[] public zombies; //public은 다른 컨트랙트에서 이 컨트랙트를 읽을 수 있음(쓸 수는 없음)

    mapping(uint => address) public zombieToOwner; //좀비 소유권을 저장하는 매핑(좀비ID를 주면 주소 반환)
    mapping(address => uint) public ownerZombieCount; //소유자의 주소를 통해 소유한 좀비 수 확인

     function _createZombie(string _name, uint _dna) internal {  //private함수의 이름은 _로 시작이 관례
       
        uint id = zombies.push(Zombie(_name, _dna)) - 1;  //좀비(구조체)를 만들어 구조체 배열 zombies에 넣어주는 함수.
        zombieToOwner[id] = msg.sender; //msg.sender - 현재 함수를 호출한 사람의 주소 반환
        ownerZombieCount[msg.sender]++;
        NewZombie(id, _name, _dna); //이벤트 실행
    } //view - 함수가 데이터를 보기만 하고 변경하지 않음. pure - 함수가 앱에서 어떤 데이터도 접근하지 않음.

    function _generateRandomDna(string _str) private view returns (uint) { //해싱을 통해 랜덤 DNA생성함수.
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

     function createRandomZombie(string _name) public  { //이름을 받아 16자리 랜덤 DNA숫자를 받고 이름과 DNA로 구조체를 만들어 구조체 배열에 push
         require(ownerZombieCount[msg.sender]==0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}