import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from "./build/index.main.mjs";
const stdlib = loadStdlib();

const startingBalance = stdlib.parseCurrency(100);
const accChinwe = await stdlib.newTestAccount(startingBalance);
const accEmeka = await stdlib.newTestAccount(startingBalance);

const ctcChinwe = accChinwe.contract(backend);
const ctcEmeka = accEmeka.contract(backend, ctcChinwe.getInfo());

const HAND = ['Rock', 'Paper', 'Scissors'];
const OUTCOME = ['Emeka Wins', 'Draw', 'Chinwe wins'];
const Player = (Who) => ({
    getHand: () => {
        const hand = Math.floor(Math.random() * 3)
        console.log(`${Who} played ${HAND[hand]}`);
        return hand;
    },
    seeOutcome: (outcome) => {
        console.log(`${Who} saw outcome ${OUTCOME[outcome]}`);
    },
})

await Promise.all([
    ctcChinwe.p.Chinwe({
        ...Player('Chinwe'),
    }),
    ctcEmeka.p.Emeka({
        ...Player('Emeka'),
    }),
]);
