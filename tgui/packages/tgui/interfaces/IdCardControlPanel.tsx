import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Flex,
} from '../components';
import { Window } from '../layouts';

type BasicID = {
  type: string;
  name: string;
  location: string;
};

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
  }>(context);

  const [cardFilterFlags, setCardFilterFlags] = useLocalState(context, "cardFilterFlags", IdFilter.All);

  const idCards = data.idCards.filter(card =>
    (typeToFilter[card.type] & cardFilterFlags)
  );

  return (
    <Window width={550} height={350}>
      <Window.Content scrollable>
        <Flex wrap="wrap" align="start">
          {Object.entries(typeToFilter).map(([type, flag]) => (
            <Flex.Item
              key={type}
              p={0.25}>
              <Button.Checkbox fill
                checked={(cardFilterFlags & flag)}
                onClick={() => { setCardFilterFlags(cardFilterFlags ^ flag); }}>
                {type}
              </Button.Checkbox>
            </Flex.Item>
          ))}
        </Flex>
        <LabeledList>
          {idCards.map(card => (
            <LabeledList.Item
              key={"someKey"}
              label={"Name:" + card.name}>
              {card.type} : {card.location}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};
