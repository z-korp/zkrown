import { FC, useEffect, useRef, useState } from "react";
import { Shield, Swords } from "lucide-react";
import { usePhase } from "@/hooks/usePhase";
import { Phase, useElementStore } from "@/utils/store";
import { useMe } from "@/hooks/useMe";
import RoundButton from "../RoundButton";
import { colorTilePlayerDark } from "@/utils/customColors";

import "../../styles/Button.css";
import { useTurn } from "@/hooks/useTurn";
import { EventType } from "@/hooks/useLogs";
import { DefendEvent, FortifyEvent, SupplyEvent } from "@/utils/events";

interface TroopsMarkerProps {
  position: { x: number; y: number };
  handlePathClick: () => void;
  troups: number;
  color: string;
  tile: any;
  containerRef: any;
}

const TroopsMarker: FC<TroopsMarkerProps> = ({
  position,
  handlePathClick,
  troups,
  color,
  tile,
  containerRef,
}) => {
  const { isItMyTurn } = useMe();

  const { turn } = useTurn();
  const [displayedTroups, setDisplayedTroups] = useState<number>(troups);
  const [markerPosition, setMarkerPosition] = useState(position);

  const [ratioElement, setRatioElement] = useState(1);
  const [containerWidthInit, setContainerWidthInit] = useState(null);
  const [initialized, setInitialized] = useState(false);
  const [flip, setFlip] = useState(false);
  const { phase } = usePhase();
  const { current_source, current_target, last_log } = useElementStore(
    (state) => state
  );
  const [shouldAnimate, setShouldAnimate] = useState(false);
  useEffect(() => {
    if (!tile) return;
    setShouldAnimate(false);
    if (isItMyTurn || !last_log) {
      return;
    }

    if (last_log.type === EventType.Supply) {
      const log = last_log.log as SupplyEvent;
      if (tile.id === log.region) {
        setShouldAnimate(true);
      }
    } else if (last_log.type === EventType.Defend) {
      const log = last_log.log as DefendEvent;
      if (tile.id === log.targetTile) {
        setShouldAnimate(true);
      }
    } else {
      const log = last_log.log as FortifyEvent;
      if (tile.id === log.fromTile) {
        setShouldAnimate(true);
      }
      if (tile.id === log.toTile) {
        setShouldAnimate(true);
      }
    }
  }, [last_log, isItMyTurn, tile]);

  const displayedTroupsRef = useRef(displayedTroups); // Add this line

  useEffect(() => {
    const duration = 500; // 3 seconds
    const stepTime = 16; // approx. 60fps
    const steps = duration / stepTime;
    const increment = (troups - displayedTroupsRef.current) / steps; // Use the ref here
    let currentStep = 0;

    const interval = setInterval(() => {
      currentStep++;
      if (currentStep <= steps) {
        displayedTroupsRef.current += increment; // Update the ref here
        setDisplayedTroups(Math.round(displayedTroupsRef.current)); // Use the ref here
      } else {
        displayedTroupsRef.current = troups; // Update the ref here
        setDisplayedTroups(troups);
        clearInterval(interval);
      }
    }, stepTime);

    return () => clearInterval(interval); // cleanup on unmount or if component updates
  }, [troups]);

  useEffect(() => {
    const updateContainerWidth = () => {
      if (!initialized && containerRef.current) {
        // Set the initial container width when it's available
        setContainerWidthInit(containerRef.current.offsetWidth);
        setInitialized(true);
      }
    };

    // Initial setup
    updateContainerWidth();

    // Listen for window resize events
    window.addEventListener("resize", handleWindowResize);

    // Clean up the event listener when the component unmounts
    return () => {
      window.removeEventListener("resize", handleWindowResize);
    };
  }, [initialized]);

  // Attach event listener when the component mounts
  useEffect(() => {
    // Add the window resize event listener to ensure that component is load
    // weird hack TBD : improve but for now i'm stuck
    window.addEventListener("resize", handleWindowResize);
    // Remove the event listener when the component unmounts
    return () => {
      window.removeEventListener("resize", handleWindowResize);
    };
  }, []);

  const handleWindowResize = () => {
    if (containerRef.current === null) return;
    if (ratioElement === 0) {
      setRatioElement(containerRef.current.offsetWidth);
    }

    if (containerRef.current) {
      if (containerWidthInit === null || containerWidthInit === 0) return;
      const ratio = containerRef.current.offsetWidth / containerWidthInit;
      //const { widthImgSvg, heightImgSvg } = imgRef.current.getBoundingClientRect();
      const new_y = (600 / 2 - position.y) * ratio;
      setMarkerPosition({ x: position.x * ratio, y: 300 - new_y });
      // Do something with containerWidth and containerHeight
    }
  };

  useEffect(() => {
    // Set up a timer that toggles the `isActive` state every second
    const interval = setInterval(() => {
      setFlip((currentFlip) => !currentFlip);
    }, 2000);

    // Clean up the interval on component unmount
    return () => clearInterval(interval);
  }, []);

  const shouldJump = (phase: Phase) => {
    if (!tile) return false;
    if (tile.owner !== turn) return false;
    if (current_source !== null) return false;
    if (!isItMyTurn) return false;

    if (phase === Phase.ATTACK || phase === Phase.FORTIFY) {
      if (tile.army > 1) return true;
    } else if (phase === Phase.DEPLOY) {
      return true;
    }
  };

  return (
    <>
      <div
        className="absolute"
        style={{
          top: `calc(${markerPosition.y}px - 30px)`,
          left: `calc(${markerPosition.x}px - 30px)`,
        }}
      >
        {phase === Phase.ATTACK && current_source === tile.id && (
          <div
            className={`blason ${flip ? "flip" : ""}`}
            onClick={() => setFlip(!flip)}
          >
            <Swords
              size={60}
              fill={colorTilePlayerDark[tile.owner + 1 || 0]}
              stroke={colorTilePlayerDark[tile.owner + 1 || 0]}
            />
          </div>
        )}
        {phase === Phase.ATTACK && current_target === tile.id && (
          <div
            className={`blason ${flip ? "flip" : ""}`}
            onClick={() => setFlip(!flip)}
          >
            <Shield
              size={60}
              fill={colorTilePlayerDark[tile.owner + 1 || 0]}
              stroke={colorTilePlayerDark[tile.owner + 1 || 0]}
            />
          </div>
        )}
      </div>
      <RoundButton
        color={color}
        onClick={handlePathClick}
        className="absolute"
        style={{
          top: `calc(${markerPosition.y}px - 15px)`,
          left: `calc(${markerPosition.x}px - 15px)`,
        }}
        shouldJump={shouldJump(phase)}
        shouldAnimate={shouldAnimate}
      >
        <span
          className="font-vt323 text-xl text-white text-with-outline"
          data-text={displayedTroups}
        >
          {displayedTroups}
        </span>
      </RoundButton>
    </>
  );
};

export default TroopsMarker;
