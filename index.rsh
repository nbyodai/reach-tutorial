'reach 0.1';

const Player = {
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
        const handChinwe = declassify(interact.getHand());
    });
    Chinwe.publish(wager, handChinwe)
        .pay(wager);
    commit();

    Emeka.only(() => {
        interact.acceptWager(wager);
        const handEmeka = declassify(interact.getHand());
    });
    Emeka.publish(handEmeka)
        .pay(wager);

    const outcome = (handChinwe + (4 - handEmeka)) % 3;
    const               [forChinwe, forEmeka] =
        outcome == 2 ?  [      2,          0] :
        outcome == 0 ?  [      0,          2] :
        /* */           [      1,          1];
    transfer(forChinwe * wager).to(Chinwe);
    transfer(forEmeka * wager).to(Emeka);
    commit();

    each([Chinwe, Emeka], () => {
        interact.seeOutcome(outcome);
    });
})
