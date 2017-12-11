pragma solidity ^0.4.13;

contract ERC20Basic {
	uint256 public totalSupply;
	function balanceOf(address who) constant returns (uint256);
	function transfer(address to, uint256 value) returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) constant returns (uint256);
	function transferFrom(address from, address to, uint256 value) returns (bool);
	function approve(address spender, uint256 value) returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
  
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
	using SafeMath for uint256;

	mapping(address => uint256) balances;

	/**
	* @dev transfer token for a specified address
	* @param _to The address to transfer to.
	* @param _value The amount to be transferred.
	*/
	function transfer(address _to, uint256 _value) returns (bool) {
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}

	/**
	* @dev Gets the balance of the specified address.
	* @param _owner The address to query the the balance of. 
	* @return An uint256 representing the amount owned by the passed address.
	*/
	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}
 
}
 
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
 
	mapping (address => mapping (address => uint256)) allowed;

	/**
	* @dev Transfer tokens from one address to another
	* @param _from address The address which you want to send tokens from
	* @param _to address The address which you want to transfer to
	* @param _value uint256 the amout of tokens to be transfered
	*/
	function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
		var _allowance = allowed[_from][msg.sender];

		// Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
		// require (_value <= _allowance);

		balances[_to] = balances[_to].add(_value);
		balances[_from] = balances[_from].sub(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
	}

	/**
	* @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
	* @param _spender The address which will spend the funds.
	* @param _value The amount of tokens to be spent.
	*/
	function approve(address _spender, uint256 _value) returns (bool) {

		// To change the approve amount you first have to reduce the addresses`
		//  allowance to zero by calling `approve(_spender, 0)` if it is not
		//  already 0 to mitigate the race condition described here:
		//  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		require((_value == 0) || (allowed[msg.sender][_spender] == 0));

		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	/**
	* @dev Function to check the amount of tokens that an owner allowed to a spender.
	* @param _owner address The address which owns the funds.
	* @param _spender address The address which will spend the funds.
	* @return A uint256 specifing the amount of tokens still available for the spender.
	*/
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
 
}
 
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
	address public owner;

	/**
	* @dev The Ownable constructor sets the original `owner` of the contract to the sender
	* account.
	*/
	function Ownable() {
		owner = msg.sender;
	}

	/**
	* @dev Throws if called by any account other than the owner.
	*/
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	/**
	* @dev Allows the current owner to transfer control of the contract to a newOwner.
	* @param newOwner The address to transfer ownership to.
	*/
	function transferOwnership(address newOwner) onlyOwner {
		require(newOwner != address(0));      
		owner = newOwner;
	}
 
}
 
/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
 
contract MintableToken is StandardToken, Ownable {
    
	event Mint(address indexed to, uint256 amount);

	event MintFinished();

	bool public mintingFinished = false;

	modifier canMint() {
		require(!mintingFinished);
		_;
	}

	/**
	* @dev Function to mint tokens
	* @param _to The address that will recieve the minted tokens.
	* @param _amount The amount of tokens to mint.
	* @return A boolean that indicates if the operation was successful.
	*/
	function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
		totalSupply = totalSupply.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		Mint(_to, _amount);
		return true;
	}

	/**
	* @dev Function to stop minting new tokens.
	* @return True if the operation was successful.
	*/
	function finishMinting() onlyOwner returns (bool) {
		mintingFinished = true;
		MintFinished();
		return true;
	}
  
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {
 
  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(address burner, uint _value) public {
    require(_value > 0);
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }
 
  event Burn(address indexed burner, uint indexed value);
 
}
 
contract BHTToken is MintableToken, BurnableToken {
    
    string public constant name = "Bounty Hunter Token";
    
    string public constant symbol = "BHT";
    
    uint32 public constant decimals = 18;

}

// Контракт краудсейла 
contract BHTCrowdsale is Ownable{
	using SafeMath for uint;

	address multisig; // Адрес получателя эфира

	address restricted; // Адрес отчислений на команду
	uint restrictedPercent; // Проценты отчислений на команду

	uint start; // Таймштамп старта периода
	uint totalStart; // Таймштамп запуска контракта
	uint period; // Кол-во дней (в тестовом минут) проведения периода краудсейла

	uint supplyLimit; // Лимит выпуска токенов

	BHTToken public token = new BHTToken(); // Токен

	uint rate; // Курс обмена на токены

	uint constant M = 1000000000000000000;

	// bool icoStarted = false;

	// Проверка кол-ва выпущенных токенов
	modifier isUnderHardcap() {
		require(token.totalSupply() < supplyLimit);
		_;
	}

	// Активен ли краудсейл
	modifier isActive() {
		require(now > start && now < start + period * 1 days); // Для продакшена - поменять минуты на дни
		_;
	}

	// modifier isStartable() {
	// 	require(!icoStarted);
	// 	_;
	// }

	// Выплата баунти
	function payBounties(address[] addrs, uint[] values) public onlyOwner {
		for(uint i = 0; i < addrs.length; i++){
			token.mint(addrs[i], values[i]);
		}
	}

	// Сжечь токены
	function burnTokens(uint _value) public {
		token.burn(msg.sender, _value);
	}

	// Завершение краудсейла
	function finishMinting() public onlyOwner {
		uint issuedTokenSupply = token.totalSupply();
		uint resTokens = issuedTokenSupply.div(100).mul(restrictedPercent);
		token.mint(restricted, resTokens);
	}

	// Получить время завешения текущего периода краудсейла
	function getPeriodEnding() public returns (uint endingTimestamp){
		return start + period * 1 days;
	}

	// Получить текущий лимит на выпуск токенов
	function getSupplyLimit() public returns (uint currentSupplyLimit){
		return supplyLimit;
	}

	// Получить состояние краудсейла
	function getPeriodStatus() public returns (bool crowdsaleActive){
		return now > start && now < start + period * 1 days;
	}

	// Старт ICO
	function startICO() onlyOwner{
		start = now;
		supplyLimit = 25500000 * M; // лимит выпуска токенов на ICO (25.5M)
		period = 24; // устанавливаем период (ICO)
	}

	//000000000000000000 - 18 нулей, добавить к сумме в целых BHT
	// Старт пре-ICO
	function BHTCrowdsale(){
		multisig = 0xb4eE29357d91152cd100fDEE1126C440Fba52157; // Записываем адрес, на который будет пересылаться эфир
		restricted = 0xb4eE29357d91152cd100fDEE1126C440Fba52157; // Записываем адрес, на который отправятся токены для команды
		restrictedPercent = 10;	// Процент команде
		start = now; // устанавливаем дату старта пре-айсио
		period = 28; // устанавливаем период (дни - продакшн/минуты - тест)
		supplyLimit = 5500000 * M; // Лимит выпуска токенов на pre-ICO (5M)
		rate = 30 * M; // Курс обмена эфира на токены (1ETH = 300 BHT = ~$1)
		totalStart = now;
	}
	
	// Автоматическая покупка токенов	
	function createTokens() isUnderHardcap isActive payable{
		uint mul = 10;
		if(now < totalStart + 7 days){
			mul = 40;
		}else if(now < totalStart + 14 days){
			mul = 35;
		}else if(now < totalStart + 21 days){
			mul = 30;
		}else if(now < totalStart + 28 days){
			mul = 25;
		}else if(now < totalStart + 29 days){
			mul = 20;
		}else if(now < totalStart + 34 days){
			mul = 18;
		}else if(now < totalStart + 38 days){
			mul = 15;
		}else if(now < totalStart + 41 days){
			mul = 12;
		}else{
			mul = 10;
		}

		multisig.transfer(msg.value); // переводим на основной кошелек
		uint tokens = rate.mul(mul).mul(msg.value).div(1 ether); // Переводим ETH в BHT
		token.mint(msg.sender, tokens); // Начисляем
	}

	// Если кто-то перевел эфир на контракт
	function() external payable{
		createTokens(); // Вызываем функцию начисления токенов
	}
}