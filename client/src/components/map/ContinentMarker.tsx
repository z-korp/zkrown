import { FC, useEffect, useState } from "react";
import RoundButton from "../RoundButton";

import "../../styles/Button.css";

interface ContinentMarkerProps {
  position: { x: number; y: number };
  name: string;
  handlePathClick: () => void;
  supply: number;
  color: string;
  containerRef: any;
}

const ContinentMarker: FC<ContinentMarkerProps> = ({
  position,
  name,
  handlePathClick,
  supply,
  color,
  containerRef,
}) => {
  const [markerPosition, setMarkerPosition] = useState(position);

  const [ratioElement, setRatioElement] = useState(1);
  const [containerWidthInit, setContainerWidthInit] = useState(null);
  const [initialized, setInitialized] = useState(false);

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

  if (supply === 0) return null;

  return (
    <>
      <div
        className="absolute"
        style={{
          top: `calc(${markerPosition.y}px - 30px)`,
          left: `calc(${markerPosition.x}px - 30px)`,
        }}
      ></div>

      <RoundButton
        color={color}
        onClick={handlePathClick}
        className="absolute w-fit px-2"
        style={{
          top: `calc(${markerPosition.y}px - 15px)`,
          left: `${markerPosition.x}px`, // Set left to x position
          transform: "translateX(-50%)", // This shifts the button left by half its own width
        }}
        shouldJump={false}
      >
        <span
          className="text-white text-with-outline font-vt323 text-xl"
          data-text={`${name} (+${supply})`}
        >{`${name} (+${supply})`}</span>
      </RoundButton>
    </>
  );
};

export default ContinentMarker;
