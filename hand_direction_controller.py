
import cv2
import time
import os

#importar MediaPipe
try:
    import mediapipe as mp
except ImportError:
    raise ImportError(
        "Módulo 'mediapipe' não encontrado. "
        "Instale com: pip install mediapipe opencv-python"
    )

#Detectar a mão com o MediaPipe Hands.
#Calcular a posição média da mão.
#Comparar essa posição com a anterior para saber para onde a mão se moveu.
class HandDirectionController:
    def __init__(self, threshold=40):
        # Inicializa MediaPipe Hands (modelo leve)
        self.mp_hands = mp.solutions.hands
        self.hands = self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=1,
            model_complexity=0,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        self.mp_draw = mp.solutions.drawing_utils
        
        # Para computar deslocamento
        self.prev_center = None
        # pixels de deslocamento mínimo para reconhecer um gesto

        self.threshold = threshold  
    #Calcula o centro da mão com base na média dos pontos detectados pela MediaPipe.
    def get_hand_center(self, landmarks, image_shape):
        h, w = image_shape
        xs = [lm.x * w for lm in landmarks]
        ys = [lm.y * h for lm in landmarks]
        return int(sum(xs) / len(xs)), int(sum(ys) / len(ys))

    def detect_direction(self, center):
        #Compara o centro atual com o anterior para determinar direção.
        #Retorna uma string: 'Cima', 'Baixo', 'Esquerda', 'Direita', ou None.
        if self.prev_center is None:
            self.prev_center = center
            return None

        dx = center[0] - self.prev_center[0]
        dy = center[1] - self.prev_center[1]
        direction = None
        # Verifica se deslocamento ultrapassa limiar
        if abs(dx) > abs(dy) and abs(dx) > self.threshold:
            direction = 'Esquerda' if dx > 0 else 'Direita'
        elif abs(dy) > abs(dx) and abs(dy) > self.threshold:
            direction = 'Baixo' if dy > 0 else 'Cima'

        # Atualiza para próximo cálculo
        if direction:
            self.prev_center = center
        return direction

    def save_direction_to_file(self, direction):
        #Salva a direção detectada no arquivo direction.txt
        with open("direction.txt", "w") as f:
            f.write(direction)

    def run(self):
        cap = cv2.VideoCapture(0)
        # Define resolução menor para performance
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 360)

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = self.hands.process(image)

            direction = None
            if results.multi_hand_landmarks:
                hand_landmarks = results.multi_hand_landmarks[0].landmark
                # Desenha landmarks
                self.mp_draw.draw_landmarks(frame, results.multi_hand_landmarks[0],
                                            self.mp_hands.HAND_CONNECTIONS)
                # Computa centro da mão
                center = self.get_hand_center(hand_landmarks, frame.shape[:2])
                # Detecta direção de movimento
                direction = self.detect_direction(center)
                # Desenha círculo no centro
                cv2.circle(frame, center, 5, (255, 0, 255), -1)

            # Mostra direção na tela
            if direction:
                cv2.putText(frame, f'Movimento: {direction}', (10, 30),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
                self.save_direction_to_file(direction)  # Salva o movimento detectado

            cv2.imshow('Controle com Movimento da Mão', frame)
            if cv2.waitKey(1) & 0xFF == 27:  # ESC para sair
                break

        cap.release()
        cv2.destroyAllWindows()

if __name__ == '__main__':
    controller = HandDirectionController(threshold=40)
    controller.run()
