import { useBackend, useLocalState } from '../backend';
import {
  Button,
  Flex,
  Section,
  LabeledList,
  Stack,
} from '../components';
import { Window } from '../layouts';

type BasicID = {
  type: string;
  name: string;
  location: string;
  ref: string;
};

type CompleteID = {
  ref: string;
  name: string;
  rank: string;
  owner: string;
  access: number[];
  wildcards: WildcardSet;
  age: number;
  hasTrim: boolean;
  trimAssignment: string;
  trimAccess: number[];
};

type WildcardSet = {
  [index: string]: Wildcard;
}

type Wildcard = {
  limit: number;
  usage: number[];
}

enum IdFilter {
  None = 0,
  BasicID = 1 << 0,
  RuinID = 1 << 1,
  BudgetID = 1 << 2,
  AdvGrey = 1 << 3,
  AdvSilver = 1 << 4,
  AdvGold = 1 << 5,
  AdvCentcom = 1 << 6,
  AdvBlack = 1 << 7,
  AdvAdmin = 1 << 8,
  AdvPrisoner = 1 << 9,
  AdvHighlander = 1 << 10,
  AdvChameleon = 1 << 11,
  BotID = 1 << 12,
  All = (1 << 13) - 1,
}

const typeToFilter = {
  "Basic": IdFilter.BasicID,
  "Ruin/Away": IdFilter.RuinID,
  "Budget": IdFilter.BudgetID,
  "Grey": IdFilter.AdvGrey,
  "Silver": IdFilter.AdvSilver,
  "Gold": IdFilter.AdvGold,
  "CentCom": IdFilter.AdvCentcom,
  "Black": IdFilter.AdvBlack,
  "Admin": IdFilter.AdvAdmin,
  "Prisoner": IdFilter.AdvPrisoner,
  "Highlander": IdFilter.AdvHighlander,
  "Chameleon": IdFilter.AdvChameleon,
  "Bot": IdFilter.BotID,
};

import { createLogger } from '../logging';
const logger = createLogger('drag');

export const IdCardControlPanel = (props, context) => {
  const { act, data } = useBackend<{
    idCards: BasicID[];
    selectedID?: CompleteID[];
  }>(context);

  const [cardFilterFlags, setCardFilterFlags] = useLocalState(context, "cardFilterFlags", IdFilter.All);

  const idCards = data.idCards.filter(card =>
    (typeToFilter[card.type] & cardFilterFlags)
  );

  const selectedID = data.selectedID;

  return (
    <Window width={560} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Filters">
              <Flex wrap="wrap" align="start" minHeight="auto">
                {Object.entries(typeToFilter).map(([type, flag]) => (
                  <Flex.Item
                    key={type}
                    p={0.25}>
                    <Button.Checkbox
                      checked={(cardFilterFlags & flag)}
                      onClick={() => { setCardFilterFlags(cardFilterFlags ^ flag); }}>
                      {type}
                    </Button.Checkbox>
                  </Flex.Item>
                ))}
              </Flex>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill title="ID Cards" scrollable>
              <Stack vertical>
                <LabeledList>
                  {idCards.map(card => (
                    <Stack.Item key={card.ref}>
                      <LabeledList.Item
                        label={"Name:" + card.name}>
                        {card.type} : {card.location}&nbsp;
                        <Button
                          onClick={() => { act("select", { ref: card.ref }); }}>
                          Select
                        </Button>
                      </LabeledList.Item>
                    </Stack.Item>
                  ))}
                </LabeledList>
              </Stack>
            </Section>
          </Stack.Item>

          {/* (!!selectedID) && (
            <Stack.Item fill>
              <Section minHeight="200px" minWidth="100%" fill>
                {JSON.stringify(selectedID)}
              </Section>
            </Stack.Item>
          )*/}
        </Stack>

      </Window.Content>
    </Window>
  );
};
