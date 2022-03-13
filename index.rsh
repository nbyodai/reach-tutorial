'reach 0.1';

const [ isHand, ROCK, PAPER, SCISSORS ] = makeEnum(3);
const [ isOutcome, B_WINS, DRAW, A_WINS ] = makeEnum(3);

const winner = (handChinwe, handEmeka) =>
    ((handChinwe + (4 - handEmeka)) % 3);

assert(winner(ROCK, PAPER) == B_WINS);
assert(winner(PAPER, ROCK) == A_WINS);
assert(winner(ROCK, ROCK) == DRAW);

forall(UInt, handChinwe =>
    forall(UInt, handEmeka =>
        assert(isOutcome(winner(handChinwe, handEmeka)))));

forall(UInt, (hand) =>
    assert(winner(hand, hand) == DRAW));

const Player = {
    ...hasRandom,
    getHand: Fun([], UInt),
    seeOutcome: Fun([UInt], Null),
};

export const main = Reach.App(() => {
    const Chinwe = Participant('Chinwe', {
        ...Player,
        wager: UInt,
    });
    const Emeka = Participant('Emeka', {
        ...Player,
        acceptWager: Fun([UInt], Null),
    });
    init();
    // write program here
    Chinwe.only(() => {
        const wager = declassify(interact.wager);
        const _handChinwe = interact.getHand();
        const [_commitChinwe, _saltChinwe] = makeCommitment(interact, _handChinwe);
        const commitChinwe = declassify(_commitChinwe);
    });
    Chinwe.publish(wager, commitChinwe)
        .pay(wager);
    commit();

    unknowable(Emeka, Chinwe(_handChinwe, _saltChinwe));
    Emeka.only(() => {
        interact.acceptWager(wager);
        const handEmeka = declassify(interact.getHand());
    });
    Emeka.publish(handEmeka)
        .pay(wager);
    commit();

    Chinwe.only(() => {
        const saltChinwe = declassify(_saltChinwe);
        const handChinwe = declassify(_handChinwe);
    });
    Chinwe.publish(saltChinwe, handChinwe);
    checkCommitment(commitChinwe, saltChinwe, handChinwe);

    const outcome = winner(handChinwe, handEmeka);
    const                    [forChinwe, forEmeka] =
        outcome == A_WINS ?  [      2,          0] :
        outcome == B_WINS ?  [      0,          2] :
        /* tie    */         [      1,          1];
    transfer(forChinwe * wager).to(Chinwe);
    transfer(forEmeka  * wager).to(Emeka);
    commit();

    each([Chinwe, Emeka], () => {
        interact.seeOutcome(outcome);
    });
})
