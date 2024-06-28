import { ArrowBigDown } from "lucide-react";
import { useState, useEffect, useRef, ReactNode, FC } from "react";
import ReactDOM from "react-dom";
import Bubble from "./Bubble";
import { useMe } from "@/hooks/useMe";
import { avatars } from "@/utils/pfps";
import { useTutorial } from "../contexts/TutorialContext";
import { Button } from "./ui/button";
import { useAudioSettings } from "@/contexts/AudioContext";

interface DynamicOverlayTutoProps {
  children: ReactNode;
  texts: string[];
  tutorialStep: string;
  paddingProps?: number;
}

interface OverlayStyle {
  top: number;
  left: number;
  width: number;
  height: number;
  borderRadius: number;
}

const initialStyle: OverlayStyle = {
  top: 0,
  left: 0,
  width: 0,
  height: 0,
  borderRadius: 0,
};

const DynamicOverlayTuto: FC<DynamicOverlayTutoProps> = ({
  tutorialStep,
  children,
  texts,
  paddingProps = 10,
}) => {
  const childRef = useRef<HTMLDivElement | null>(null);
  const [overlayStyle, setOverlayStyle] = useState<OverlayStyle>(initialStyle);
  const { me } = useMe();
  const { showTuto, setShowTuto, currentStep, nextStep } = useTutorial();

  const { playSound } = useAudioSettings();

  const handleNextStep = () => {
    nextStep();
  };

  useEffect(() => {
    const updateOverlayStyle = () => {
      if (childRef.current instanceof HTMLDivElement) {
        const { top, left, width, height } =
          childRef.current.getBoundingClientRect();
        const padding = paddingProps;
        const borderRadius = 10;
        setOverlayStyle({
          top: top - padding + window.scrollY,
          left: left - padding + window.scrollX,
          width: width + padding * 2,
          height: height + padding * 2,
          borderRadius: borderRadius,
        });
      }
    };

    updateOverlayStyle(); // Update initially

    const observer = new ResizeObserver(updateOverlayStyle);
    if (childRef.current) {
      observer.observe(childRef.current);
    }

    return () => {
      if (childRef.current) {
        observer.unobserve(childRef.current);
      }
    };
  }, [children]);

  function handleClose() {
    setShowTuto(false);
    playSound("backgroundMusic");
  }

  let image = undefined;
  if (me !== null && me.index + 1 < avatars.length) {
    image = avatars[me.index + 1];
  }

  const overlayContent = showTuto && currentStep === tutorialStep && (
    <>
      <div
        className="fixed inset-0 z-40"
        style={{
          boxShadow: `0 0 0 9999px rgba(0, 0, 0, 0.8)`,
          ...overlayStyle,
        }}
      >
        {/* Cet élément sert de trou transparent et d'overlay. */}
        <div
          className="absolute animate-arrow-bounce z-50"
          style={{
            left: `${overlayStyle.width / 2}px`,
          }}
        >
          <ArrowBigDown
            fill="white"
            stroke="white"
            className="w-20 h-20"
            style={{ transform: "translateX(-50%) translateY(-120%)" }}
          />
        </div>
      </div>
      <div className="fixed top-0 left-0 w-full h-full flex items-center justify-center z-50">
        <button
          onClick={handleClose}
          className="absolute top-6 right-6 p-1 w-6 h-6 bg-red-500 text-white rounded-full text-xs"
        >
          ✕
        </button>
        <div className="absolute flex justify-center items-center gap-6 top-6">
          <div className="w-32 h-32">
            <img
              src={image}
              alt="player"
              className="rounded-full object-cover w-full h-full mt-1"
            />
          </div>
          <Bubble texts={texts} variant="speechLeft" />
        </div>
        <Button
          size="lg"
          variant="tertiary"
          className="bg-green-500"
          onClick={handleNextStep}
        >
          Next Step
        </Button>
      </div>
    </>
  );

  return (
    <>
      <div ref={childRef}>{children}</div>
      {ReactDOM.createPortal(overlayContent, document.body)}
    </>
  );
};

export default DynamicOverlayTuto;
