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
})

await Promise.all([
    ctcChinwe.p.Chinwe({
        ...Player('Chinwe'),
        wager: stdlib.parseCurrency(5)
    }),
    ctcEmeka.p.Emeka({
        ...Player('Emeka'),
        acceptWager: (amt) => {
            console.log(`Emeka accepts the wager of ${fmt(amt)}.`);
        },
    }),
]);

const afterChinwe = await getBalance(accChinwe);
const afterEmeka = await getBalance(accEmeka);

console.log(`Alice went from ${beforeChinwe} to ${afterChinwe}.`);
console.log(`Bob went from ${beforeEmeka} to ${afterEmeka}.`);
