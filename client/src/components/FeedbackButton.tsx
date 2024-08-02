import { useState } from "react";
import { Mail } from "lucide-react";
import { Button } from "./ui/button";
import { Tooltip, TooltipContent, TooltipTrigger } from "./ui/tooltip";
import GoogleFormEmbed from "./GoogleformEmbedded";

const FeedbackButton = () => {
  const [showForm, setShowForm] = useState(false);

  return (
    <>
      <Tooltip>
        <TooltipTrigger asChild>
          <Button variant="secondary" onClick={() => setShowForm(true)}>
            <Mail />
          </Button>
        </TooltipTrigger>
        <TooltipContent className="px-2 py-0 font-vt323" side="top">
          Give feedback to win some STRK
        </TooltipContent>
      </Tooltip>

      {showForm && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center z-50">
          <div className="bg-white p-4 rounded-lg w-4/5 h-4/5 relative">
            <button
              className="absolute top-2 right-2 text-gray-600 hover:text-gray-800"
              onClick={() => setShowForm(false)}
            >
              X
            </button>
            <GoogleFormEmbed />
          </div>
        </div>
      )}
    </>
  );
};

export default FeedbackButton;
