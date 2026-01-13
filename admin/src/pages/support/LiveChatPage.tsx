import { useState, useEffect, useRef } from "react";
import { useTranslation } from "react-i18next";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { chatApi, type ChatSession } from "@/api/chat.api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  MessageCircle,
  Send,
  Loader2,
  UserCheck,
  Clock,
  CheckCircle,
  Star,
  XCircle,
  Users,
} from "lucide-react";
import { getInitials, formatDate, cn } from "@/lib/utils";

export function LiveChatPage() {
  const { t, i18n } = useTranslation();
  const queryClient = useQueryClient();
  const locale = i18n.language === "ar" ? "ar-SA" : "en-US";
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const [selectedSession, setSelectedSession] = useState<ChatSession | null>(
    null
  );
  const [messageInput, setMessageInput] = useState("");

  // Queries
  const { data: stats } = useQuery({
    queryKey: ["chat-stats"],
    queryFn: chatApi.getStats,
    refetchInterval: 10000, // Refresh every 10 seconds
  });

  const { data: waitingSessions = [], isLoading: waitingLoading } = useQuery({
    queryKey: ["chat-waiting"],
    queryFn: chatApi.getWaitingSessions,
    refetchInterval: 5000,
  });

  const { data: mySessions = [], isLoading: mySessionsLoading } = useQuery({
    queryKey: ["chat-my-sessions"],
    queryFn: chatApi.getMySessions,
    refetchInterval: 5000,
  });

  const { data: sessionData, isLoading: sessionLoading } = useQuery({
    queryKey: ["chat-session", selectedSession?._id],
    queryFn: () => chatApi.getSession(selectedSession!._id),
    enabled: !!selectedSession?._id,
    refetchInterval: 3000,
  });

  // Mutations
  const acceptMutation = useMutation({
    mutationFn: chatApi.acceptSession,
    onSuccess: (session) => {
      queryClient.invalidateQueries({ queryKey: ["chat-waiting"] });
      queryClient.invalidateQueries({ queryKey: ["chat-my-sessions"] });
      setSelectedSession(session);
    },
  });

  const sendMessageMutation = useMutation({
    mutationFn: ({
      sessionId,
      content,
    }: {
      sessionId: string;
      content: string;
    }) => chatApi.sendMessage(sessionId, content),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["chat-session"] });
      setMessageInput("");
    },
  });

  const endSessionMutation = useMutation({
    mutationFn: chatApi.endSession,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["chat-my-sessions"] });
      setSelectedSession(null);
    },
  });

  // Auto scroll to bottom
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [sessionData?.messages]);

  const handleSendMessage = () => {
    if (!selectedSession || !messageInput.trim()) return;
    sendMessageMutation.mutate({
      sessionId: selectedSession._id,
      content: messageInput,
    });
  };

  const handleAccept = (session: ChatSession) => {
    acceptMutation.mutate(session._id);
  };

  const handleEndSession = () => {
    if (!selectedSession) return;
    endSessionMutation.mutate(selectedSession._id);
  };

  const messages = sessionData?.messages || [];

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
            {t("sidebar.liveChat")}
          </h1>
          <p className="text-gray-500 dark:text-gray-400 mt-1">
            المحادثات المباشرة مع العملاء
          </p>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <div className="p-3 bg-yellow-100 dark:bg-yellow-900/30 rounded-xl">
              <Clock className="h-5 w-5 text-yellow-600" />
            </div>
            <div>
              <p className="text-2xl font-bold">
                {stats?.waiting || waitingSessions.length}
              </p>
              <p className="text-sm text-gray-500">بالانتظار</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <div className="p-3 bg-green-100 dark:bg-green-900/30 rounded-xl">
              <MessageCircle className="h-5 w-5 text-green-600" />
            </div>
            <div>
              <p className="text-2xl font-bold">
                {stats?.active || mySessions.length}
              </p>
              <p className="text-sm text-gray-500">نشطة</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <div className="p-3 bg-blue-100 dark:bg-blue-900/30 rounded-xl">
              <CheckCircle className="h-5 w-5 text-blue-600" />
            </div>
            <div>
              <p className="text-2xl font-bold">{stats?.todayEnded || 0}</p>
              <p className="text-sm text-gray-500">منتهية اليوم</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <div className="p-3 bg-purple-100 dark:bg-purple-900/30 rounded-xl">
              <Star className="h-5 w-5 text-purple-600" />
            </div>
            <div>
              <p className="text-2xl font-bold">
                {stats?.avgRating?.toFixed(1) || "-"}
              </p>
              <p className="text-sm text-gray-500">متوسط التقييم</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Chat Interface */}
      <div className="grid lg:grid-cols-3 gap-6">
        {/* Sessions List */}
        <div className="space-y-4">
          {/* Waiting Sessions */}
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-lg flex items-center gap-2">
                <Clock className="h-4 w-4 text-yellow-500" />
                بالانتظار
                {waitingSessions.length > 0 && (
                  <Badge variant="warning">{waitingSessions.length}</Badge>
                )}
              </CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              {waitingLoading ? (
                <div className="flex items-center justify-center py-6">
                  <Loader2 className="h-6 w-6 animate-spin text-primary-600" />
                </div>
              ) : waitingSessions.length === 0 ? (
                <div className="py-6 text-center text-gray-500 text-sm">
                  لا توجد محادثات بالانتظار
                </div>
              ) : (
                <div className="divide-y dark:divide-slate-700">
                  {waitingSessions.map((session) => (
                    <div
                      key={session._id}
                      className="p-3 flex items-center justify-between"
                    >
                      <div className="flex items-center gap-3">
                        <Avatar className="h-8 w-8">
                          <AvatarFallback className="text-xs">
                            {getInitials(
                              session.customer?.companyName || "عميل"
                            )}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <p className="text-sm font-medium">
                            {session.customer?.companyName || "عميل"}
                          </p>
                          <p className="text-xs text-gray-500">
                            {formatDate(session.startedAt, locale)}
                          </p>
                        </div>
                      </div>
                      <Button
                        size="sm"
                        onClick={() => handleAccept(session)}
                        disabled={acceptMutation.isPending}
                      >
                        <UserCheck className="h-4 w-4" />
                      </Button>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* My Sessions */}
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-lg flex items-center gap-2">
                <MessageCircle className="h-4 w-4 text-green-500" />
                محادثاتي
              </CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              {mySessionsLoading ? (
                <div className="flex items-center justify-center py-6">
                  <Loader2 className="h-6 w-6 animate-spin text-primary-600" />
                </div>
              ) : mySessions.length === 0 ? (
                <div className="py-6 text-center text-gray-500 text-sm">
                  لا توجد محادثات نشطة
                </div>
              ) : (
                <div className="divide-y dark:divide-slate-700">
                  {mySessions.map((session) => (
                    <div
                      key={session._id}
                      onClick={() => setSelectedSession(session)}
                      className={cn(
                        "p-3 cursor-pointer hover:bg-gray-50 dark:hover:bg-slate-800 transition-colors",
                        selectedSession?._id === session._id &&
                          "bg-primary-50 dark:bg-primary-900/20"
                      )}
                    >
                      <div className="flex items-center gap-3">
                        <Avatar className="h-8 w-8">
                          <AvatarFallback className="text-xs">
                            {getInitials(
                              session.customer?.companyName || "عميل"
                            )}
                          </AvatarFallback>
                        </Avatar>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center justify-between">
                            <p className="text-sm font-medium truncate">
                              {session.customer?.companyName || "عميل"}
                            </p>
                            {session.unreadCount && session.unreadCount > 0 && (
                              <Badge variant="danger" className="text-xs">
                                {session.unreadCount}
                              </Badge>
                            )}
                          </div>
                          <p className="text-xs text-gray-500 truncate">
                            {session.currentPage || "-"}
                          </p>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </div>

        {/* Chat Area */}
        <div className="lg:col-span-2">
          <Card className="h-[600px] flex flex-col">
            {selectedSession ? (
              <>
                {/* Chat Header */}
                <CardHeader className="pb-3 border-b dark:border-slate-700">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <Avatar>
                        <AvatarFallback>
                          {getInitials(
                            selectedSession.customer?.companyName || "عميل"
                          )}
                        </AvatarFallback>
                      </Avatar>
                      <div>
                        <p className="font-medium">
                          {selectedSession.customer?.companyName || "عميل"}
                        </p>
                        <p className="text-xs text-gray-500">
                          {selectedSession.customer?.contactName}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Badge
                        variant={
                          selectedSession.status === "active"
                            ? "success"
                            : "default"
                        }
                      >
                        {selectedSession.status === "active" ? "نشط" : "منتهي"}
                      </Badge>
                      {selectedSession.status === "active" && (
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={handleEndSession}
                          disabled={endSessionMutation.isPending}
                        >
                          <XCircle className="h-4 w-4" />
                          إنهاء
                        </Button>
                      )}
                    </div>
                  </div>
                </CardHeader>

                {/* Messages */}
                <CardContent className="flex-1 overflow-y-auto p-4 space-y-4">
                  {sessionLoading ? (
                    <div className="flex items-center justify-center h-full">
                      <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                    </div>
                  ) : messages.length === 0 ? (
                    <div className="flex items-center justify-center h-full text-gray-500">
                      <p>لا توجد رسائل</p>
                    </div>
                  ) : (
                    <>
                      {messages.map((message) => (
                        <div
                          key={message._id}
                          className={cn(
                            "flex",
                            message.sender === "agent"
                              ? "justify-end"
                              : "justify-start"
                          )}
                        >
                          <div
                            className={cn(
                              "max-w-[70%] rounded-2xl px-4 py-2",
                              message.sender === "agent"
                                ? "bg-primary-600 text-white rounded-br-sm"
                                : "bg-gray-100 dark:bg-slate-800 text-gray-900 dark:text-gray-100 rounded-bl-sm"
                            )}
                          >
                            <p className="text-sm">{message.content}</p>
                            <p
                              className={cn(
                                "text-xs mt-1",
                                message.sender === "agent"
                                  ? "text-primary-200"
                                  : "text-gray-500"
                              )}
                            >
                              {new Date(message.createdAt).toLocaleTimeString(
                                "ar-SA",
                                { hour: "2-digit", minute: "2-digit" }
                              )}
                            </p>
                          </div>
                        </div>
                      ))}
                      <div ref={messagesEndRef} />
                    </>
                  )}
                </CardContent>

                {/* Input */}
                {selectedSession.status === "active" && (
                  <div className="p-4 border-t dark:border-slate-700">
                    <div className="flex gap-2">
                      <Input
                        value={messageInput}
                        onChange={(e) => setMessageInput(e.target.value)}
                        placeholder="اكتب رسالتك..."
                        onKeyPress={(e) =>
                          e.key === "Enter" && handleSendMessage()
                        }
                      />
                      <Button
                        onClick={handleSendMessage}
                        disabled={
                          !messageInput.trim() || sendMessageMutation.isPending
                        }
                      >
                        {sendMessageMutation.isPending ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <Send className="h-4 w-4" />
                        )}
                      </Button>
                    </div>
                  </div>
                )}
              </>
            ) : (
              <CardContent className="flex-1 flex items-center justify-center text-gray-500">
                <div className="text-center">
                  <Users className="h-16 w-16 mx-auto mb-4 text-gray-300" />
                  <p>اختر محادثة للبدء</p>
                </div>
              </CardContent>
            )}
          </Card>
        </div>
      </div>
    </div>
  );
}

export default LiveChatPage;
