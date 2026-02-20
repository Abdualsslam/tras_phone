import { Component, type ReactNode } from "react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error("[ErrorBoundary]", error, info.componentStack);
  }

  private handleReset = () => {
    this.setState({ hasError: false, error: null });
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) return this.props.fallback;

      return (
        <div
          dir="rtl"
          className="flex min-h-screen items-center justify-center bg-gray-50 p-6"
        >
          <div className="w-full max-w-md rounded-xl bg-white p-8 text-center shadow-lg">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-red-100 text-3xl">
              ⚠️
            </div>
            <h2 className="mb-2 text-xl font-semibold text-gray-900">
              حدث خطأ غير متوقع
            </h2>
            <p className="mb-6 text-sm text-gray-500">
              نعتذر عن هذا الخطأ. يرجى المحاولة مرة أخرى.
            </p>
            {this.state.error && (
              <pre className="mb-6 max-h-32 overflow-auto rounded bg-gray-100 p-3 text-left text-xs text-gray-600">
                {this.state.error.message}
              </pre>
            )}
            <div className="flex justify-center gap-3">
              <button
                onClick={this.handleReset}
                className="rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-blue-700"
              >
                حاول مرة أخرى
              </button>
              <button
                onClick={() => (window.location.href = "/")}
                className="rounded-lg border border-gray-300 px-5 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                الصفحة الرئيسية
              </button>
            </div>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
