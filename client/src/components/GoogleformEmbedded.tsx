const GoogleFormEmbed = () => {
  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      <iframe
        src="https://forms.gle/tUmg9XCEicv1HZrX6"
        width="100%"
        height="100%"
        style={{
          borderRadius: "15px",
          overflow: "hidden",
        }}
      >
        Loading…
      </iframe>
    </div>
  );
};

export default GoogleFormEmbed;
