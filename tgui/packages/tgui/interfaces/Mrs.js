import { useBackend } from '../backend';
import { round, toFixed } from 'common/math';
import { Box, Section, LabeledList, Button, ProgressBar, Flex } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';
import { FlexItem } from '../components/Flex';

export const Mrs = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    open,
    occupant = {},
    occupied,
  } = data;
  const organs = data.occupant.organs || [];
  const Btrauma = data.occupant.traumalist || [];
  const missingOrgans = data.occupant.missing_organs || [];

  return (
    <Window
      width={480}
      height={700}>
      <Window.Content>
        <Section
          title={occupant.name ? occupant.name : 'No Occupant'}
          minHeight="80px"
          buttons={!!occupant.stat && (
            <Box
              inline
              bold
              color={occupant.statstate}>
              {occupant.stat}
            </Box>
          )}>
          Overall health:
          {!!occupied && (
            <ProgressBar
              value={occupant.health}
              minValue={occupant.minHealth}
              maxValue={occupant.maxHealth}
              ranges={{
                good: [50, Infinity],
                average: [0, 50],
                bad: [-Infinity, 0],
              }} />
          )}
        </Section>


        <Section title={"Controls"}>
          <Button
            icon={open ? 'door-open' : 'door-closed'}
            content={open ? 'Open' : 'Closed'}
            onClick={() => act('door')} />
          <Button
            icon={'power-off'}
            content={data.scanning ? 'Scanning' : 'Scan'}
            disabled={!data.occupant}
            selected={data.scanning}
            onClick={() => act('scan')} />
          {!!data.scanning && (
            <ProgressBar
              title={"Scanning..."}
              minValue={0}
              maxValue={data.scantime}
              value={data.scancount} />
          )}
        </Section>


        {!!occupied && (
          <Section
            title={'Organ Status'}
            minHeight="420px">

            {/* Process each organ in an incredbily janky way */}
            <LabeledList>
              {organs.map(organ => (
                <LabeledList.Item
                  key={organ.name}
                  label={organ.name}>
                  Damage:

                  <ProgressBar
                    title={'Health'}
                    value={organ.damage}
                    minValue={0}
                    maxValue={organ.max_damage}
                    textAlign={"center"}
                    ranges={{
                      good: [-Infinity, 30],
                      average: [30, 70],
                      bad: [70, Infinity],
                    }}>{organ.state}
                  </ProgressBar>

                  {organ.slot === "BRAIN" && (
                    data.occupant.traumalist && (
                      Btrauma.map(trauma => (
                        <LabeledList.Item
                          key={trauma.Bname}
                          color={trauma.colourB}>
                          {trauma.resist} {trauma.Bname}
                        </LabeledList.Item>
                      ))
                    ) || (
                      <Box
                        color={'good'}>
                        {"No traumas detected"}
                      </Box>)
                  )}

                  {organ.slot === "HEART" && (
                    <Flex
                      height="100%"
                      width="100%"
                      direction="row">

                      <Flex.Item grow={1}>
                        Blood volume:
                      </Flex.Item>
                      <Flex.Item grow={2}>
                        <ProgressBar
                          minValue={0}
                          maxValue={data.occupant.blood.maxBloodVolume}
                          value={round(data.occupant.blood.currentBloodVolume)}
                          ranges={{
                            good: [data.occupant.blood.dangerBloodVolume,
                              Infinity],
                            average: [(data.occupant.blood.maxBloodVolume / 2),
                              data.occupant.blood.dangerBloodVolume],
                            bad: [-Infinity,
                              (data.occupant.blood.maxBloodVolume / 2)],
                          }}>
                          {round(data.occupant.blood.currentBloodVolume)} cl
                        </ProgressBar>
                      </Flex.Item>
                    </Flex>
                  )}

                  {organ.name === "LIVER" && (
                    <Flex
                      height="100%"
                      width="100%"
                      direction="row">

                      <Flex.Item grow={1}>
                        Metabolic Stress:
                      </Flex.Item>
                      <Flex.Item grow={2}>
                        <ProgressBar
                          minValue={data.occupant.metabolicStressMin}
                          maxValue={data.occupant.metabolicStressMax}
                          value={data.occupant.metabolicStressVal}
                          ranges={{
                            violet: [-Infinity, -10],
                            blue: [-10, 0],
                            good: [0, 15],
                            average: [15, 40],
                            bad: [40, Infinity],
                          }}>
                          {data.occupant.metabolicStress}
                        </ProgressBar>
                      </Flex.Item>
                    </Flex>
                  )}

                  {organ.slot === "STOMACH" && (
                    data.occupant.pH && (
                      <Flex
                        height="100%"
                        width="100%"
                        direction="row">

                        <Flex.Item grow={1}>
                          <Box color={data.occupant.stomachColor}>
                            Volume: {data.occupant.stomachVol}u
                          </Box>
                        </Flex.Item>
                        <FlexItem grow={2}>
                          <ProgressBar
                            minValue={0}
                            maxValue={14}
                            label={data.occupant.pH}
                            value={data.occupant.pH}
                            color={data.occupant.pHcolor}
                            title={data.occupant.pHState}>
                            {data.occupant.pHState}
                          </ProgressBar>
                        </FlexItem>
                      </Flex>
                    )

                  )}

                  {organ.slot === "LUNGS" && (
                    !!data.occupant.lungcollapse && (
                      <Box
                        color={'average'}>
                        {data.occupant.lungcollapse}
                      </Box>
                    ) || (
                      <Box
                        color={'good'}>
                        {"Both lobes intact"}
                      </Box>
                    )
                  )}
                </LabeledList.Item>
              ))}
              {missingOrgans.map(mOrgan => (
                <LabeledList.Item
                  key={mOrgan.name}
                  label={mOrgan.name}>
                  <Box
                    color={'bad'}>
                    {'MISSING'}
                  </Box>
                </LabeledList.Item>))}
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};