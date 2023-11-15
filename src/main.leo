program token.aleo {

    mapping account:address => u64;

    record Token {
        owner: address,
        amount: u64,
    }

    transition mint_public(public receiver: address, public amount: u64) {
        return then finalize(receiver, amount);
    }
    
    finalize mint_public (public receiver: address,public amount: u64) {
        let receiver_amount: u64 = Mapping::get_or_use(account,receiver,0u64 );
        Mapping::set(account,receiver ,receiver_amount);
    }

    transition mint_private(receiver: address, amount: u64) -> Token {
        return Token {
            owner:receiver,
            amount: amount
        };
    }

    transition transfer_public(public receiver:address, public amount:u64){
        return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public(public sender:address,public receiver: address, public amount:u64){
        let sender_amount:u64 = Mapping::get_or_use(account,sender ,0u64 );
        Mapping::set(account,sender ,sender_amount - amount );

        let receiver_amount:u64 = Mapping::get_or_use(account,receiver,0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition transfer_private(sender:Token, receiver: address, amount:u64) -> (Token,Token){
        let difference:u64 = sender.amount - amount;

        let remaining: Token = Token{
            owner: sender.owner,
            amount: difference
        };

        let transferred : Token = Token {
            owner: receiver,
            amount: amount
        };
        return (remaining, transferred);
    }

    transition private_to_public (sender: Token, public receiver:address, public amount:u64) -> Token {
        let difference: u64 = sender.amount - amount;

        let remaining: Token = Token {
            owner: sender.owner,
            amount: difference
        };

        return remaining then finalize(receiver,amount);
    }

    finalize private_to_public(public receiver: address, public amount: u64) {
        let receiver_amount:u64 = Mapping::get_or_use(account,receiver ,0u64 );
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition public_to_private(public receiver:address, public amount:u64) -> Token{
        let transferred: Token= Token{
            owner: receiver,
            amount: amount
        };

        return transferred then finalize(self.caller, amount);
    }

    finalize public_to_private (public sender:address, public amount: u64) {
        let sender_amount:u64 =  Mapping::get_or_use(account,sender, 0u64 );
        Mapping::set(account, sender, sender_amount - amount);

    }

    
}