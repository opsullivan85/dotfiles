import argparse

from faster_whisper import WhisperModel


def main() -> None:
    parser = argparse.ArgumentParser(description="Transcribe an audio or video file with faster-whisper.")
    parser.add_argument("audio", help="path to the audio or video file")
    parser.add_argument(
        "--model",
        default="small",
        help="model size or local model path (default: small)",
    )
    parser.add_argument(
        "--language",
        help="language code such as en (default: auto-detect)",
    )
    parser.add_argument("--device", default="auto", help="cpu, cuda, or auto (default: auto)")
    parser.add_argument("--compute-type", default="auto", help="e.g. int8, float16 (default: auto)")
    args = parser.parse_args()

    model = WhisperModel(args.model, device=args.device, compute_type=args.compute_type)
    segments, _info = model.transcribe(args.audio, language=args.language)
    for segment in segments:
        print(segment.text.strip())


if __name__ == "__main__":
    main()
