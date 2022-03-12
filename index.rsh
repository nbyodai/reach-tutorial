'reach 0.1';

const Player = {
    getHand: Fun([], UInt),
    seeOutcome: Fun([UInt], Null),
};

export const main = Reach.App(() => {
    const Chinwe = Participant('Chinwe', {
        ...Player,
    });
    const Emeka = Participant('Emeka', {
        ...Player,
    });
    init();
    // write program here
    Chinwe.only(() => {
        const handChinwe = declassify(interact.getHand());
    });
    Chinwe.publish(handChinwe);
    commit();

    Emeka.only(() => {
        const handEmeka = declassify(interact.getHand());
    });
    Emeka.publish(handEmeka);

    const outcome = (handChinwe + (4 - handEmeka)) % 3;
    commit();

    each([Chinwe, Emeka], () => {
        interact.seeOutcome(outcome);
    });
})
