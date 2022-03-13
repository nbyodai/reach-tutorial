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
    informTimeout: Fun([], Null),
};

export const main = Reach.App(() => {
    const Chinwe = Participant('Chinwe', {
        ...Player,
        wager: UInt,
        deadline: UInt,
    });
    const Emeka = Participant('Emeka', {
        ...Player,
        acceptWager: Fun([UInt], Null),
    });
    init();
    // write program here
    const informTimeout = () => {
        each([Chinwe, Emeka], () => {
            interact.informTimeout();
        });
    };

    Chinwe.only(() => {
        const wager = declassify(interact.wager);
        const deadline = declassify(interact.deadline)
    })
    Chinwe.publish(wager, deadline)
        .pay(wager);
    commit();

    Emeka.only(() => {
        interact.acceptWager(wager);
    });
    Emeka.pay(wager)
        .timeout(relativeTime(deadline), () => closeTo(Chinwe, informTimeout));

    var outcome = DRAW;
    invariant( balance() == 2 * wager && isOutcome(outcome) );
    while (outcome == DRAW ){
        commit();

        Chinwe.only(() => {
            const _handChinwe = interact.getHand();
            const [_commitChinwe, _saltChinwe] = makeCommitment(interact, _handChinwe);
            const commitChinwe = declassify(_commitChinwe);
        });
        Chinwe.publish(commitChinwe)
            .timeout(relativeTime(deadline), () => closeTo(Emeka, informTimeout));
        commit();

        unknowable(Emeka, Chinwe(_handChinwe, _saltChinwe));
        Emeka.only(() => {
            const handEmeka = declassify(interact.getHand());
        });
        Emeka.publish(handEmeka)
            .timeout(relativeTime(deadline), () => closeTo(Chinwe, informTimeout));
        commit();

        Chinwe.only(() => {
            const saltChinwe = declassify(_saltChinwe);
            const handChinwe = declassify(_handChinwe);
        });
        Chinwe.publish(saltChinwe, handChinwe)
            .timeout(relativeTime(deadline), () => closeTo(Emeka, informTimeout));
        checkCommitment(commitChinwe, saltChinwe, handChinwe);

        outcome = winner(handChinwe, handEmeka);
        continue;
    }

    assert(outcome == A_WINS || outcome == B_WINS)
    transfer(2 * wager).to(outcome == A_WINS ? Chinwe : Emeka);
    commit();

    each([Chinwe, Emeka], () => {
        interact.seeOutcome(outcome);
    });
})
