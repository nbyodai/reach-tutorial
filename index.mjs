import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from "./build/index.main.mjs";
const stdlib = loadStdlib();

const startingBalance = stdlib.parseCurrency(100);
const accChinwe = await stdlib.newTestAccount(startingBalance);
const accEmeka = await stdlib.newTestAccount(startingBalance);

const fmt = (x) => stdlib.formatCurrency(x,4);
const getBalance = async (who) => fmt(await stdlib.balanceOf(who));
const beforeChinwe = await getBalance(accChinwe);
const beforeEmeka = await getBalance(accEmeka);

const ctcChinwe = accChinwe.contract(backend);
const ctcEmeka = accEmeka.contract(backend, ctcChinwe.getInfo());

const HAND = ['Rock', 'Paper', 'Scissors'];
const OUTCOME = ['Emeka Wins', 'Draw', 'Chinwe wins'];
const Player = (Who) => ({
    ...stdlib.hasRandom,
    getHand: () => {
        const hand = Math.floor(Math.random() * 3)
        console.log(`${Who} played ${HAND[hand]}`);
        return hand;
    },
    seeOutcome: (outcome) => {
        console.log(`${Who} saw outcome ${OUTCOME[outcome]}`);
    },
    informTimeout: () => {
        console.log(`${Who} observed a timeout`);
    },
})

await Promise.all([
    ctcChinwe.p.Chinwe({
        ...Player('Chinwe'),
        wager: stdlib.parseCurrency(5),
        deadline: 10,
    }),
    ctcEmeka.p.Emeka({
        ...Player('Emeka'),
        acceptWager: async (amt) => {
            if ( Math.random() <= 0.5 ) {
                for (let i = 0; i < 10; i++) {
                    console.log(` Emeka takes his sweet time...`);
                    await stdlib.wait(1);
                }
            } else {
                console.log(`Emeka accepts the wager of ${fmt(amt)}.`);
            }
        },
    }),
]);

const afterChinwe = await getBalance(accChinwe);
const afterEmeka = await getBalance(accEmeka);

console.log(`Chinwe went from ${beforeChinwe} to ${afterChinwe}.`);
console.log(`Emeka went from ${beforeEmeka} to ${afterEmeka}.`);
