interface ERC20 {
    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Kghost0 is ERC20 {
    uint256 private _totalSupply;
    uint256 private creationTime;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;
    mapping(address => uint256) private lastClaimedTime;

    function Kghost0(){
        creationTime = block.timestamp;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        claimTokensFor(msg.sender);
        require(amount <= balances[msg.sender]);

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) public returns (bool) {
        claimTokensFor(msg.sender);
        require(tokens <= allowed[from][msg.sender] && tokens <= balances[from]);

        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][msg.sender] -= tokens;

        emit Transfer(from, to, tokens);
        return true;
    }

    function approve(address approvee, uint256 amount) public returns (bool) {
        claimTokensFor(msg.sender);
        allowed[msg.sender][approvee] = amount;
        emit Approval(msg.sender, approvee, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint256) {
        return allowed[tokenOwner][spender];
    }

    function balanceOf(address tokenOwner) public constant returns (uint256){
        return balances[tokenOwner] + balanceOfUnclaimed(tokenOwner);
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function balanceOfUnclaimed(address tokenOwner) internal constant returns (uint256) {
        uint256 frequency = 3600;
        if (balances[tokenOwner] < 100 && creationTime - lastClaimedTime[tokenOwner] > frequency) {
            return creationTime - lastClaimedTime[tokenOwner] / frequency;
        } else {
            return 0;
        }
    }

    function claimTokensFor(address tokenOwner) internal {
        uint256 _balanceOfUnclaimed = balanceOfUnclaimed(tokenOwner);
        if(_balanceOfUnclaimed > 0 ){
            balances[tokenOwner] += _balanceOfUnclaimed;
            lastClaimedTime[tokenOwner] = block.timestamp;
            _totalSupply += _balanceOfUnclaimed;
        }
    }
}