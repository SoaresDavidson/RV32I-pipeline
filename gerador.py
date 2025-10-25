import tkinter as tk
from tkinter import ttk, messagebox

# --- 1. Mapeamentos de Tipos e Tamanhos de Campo ---

# Define os campos necessários para cada tipo de instrução e o tamanho do campo imediato
TYPE_MAP = {
    "R (Reg-Reg)": {"fields": ["opcode", "funct3", "funct7", "rs1", "rs2", "rd"], "imm_bits": 0},
    "I (Immediate)": {"fields": ["opcode", "funct3", "rs1", "rd", "imm"], "imm_bits": 12},
    "S (Store)": {"fields": ["opcode", "funct3", "rs1", "rs2", "imm"], "imm_bits": 12},
    "B (Branch)": {"fields": ["opcode", "funct3", "rs1", "rs2", "imm"], "imm_bits": 13}, # 13 bits de range, 12 no formato
    "U (Upper Imm)": {"fields": ["opcode", "rd", "imm"], "imm_bits": 20},
    "J (Jump)": {"fields": ["opcode", "rd", "imm"], "imm_bits": 21}, # 21 bits de range, 20 no formato
}

# --- 2. Funções de Conversão e Formatação ---

def int_to_bin_signed(value: int, bits: int) -> str:
    """Converte um inteiro para binário em complemento de dois com um número fixo de bits."""
    if value >= 0:
        return bin(value)[2:].zfill(bits)
    else:
        # Complemento de dois
        return bin((1 << bits) + value)[2:]

def get_field_bits(field: str) -> int:
    """Retorna o número de bits para cada campo padrão."""
    if field in ["rs1", "rs2", "rd"]:
        return 5
    elif field in ["funct3", "opcode_7"]: # Opcode de 7 bits (usado para checagem)
        return 7
    elif field == "funct3":
        return 3
    elif field == "funct7":
        return 7
    return 0

# --- 3. Função Principal de Geração de Binário ---

def generate_binary_by_type(instr_type_key: str, fields: dict) -> str:
    """Gera o binário dado o tipo de instrução e todos os campos binários/inteiros."""
    
    instr_type_str = instr_type_key.split(' ')[0]
    
    # 1. Obter e Validar Campos
    try:
        opcode = fields['opcode']
        rd = fields['rd']
        rs1 = fields['rs1']
        rs2 = fields.get('rs2', '00000') 
        funct3 = fields.get('funct3', '000')
        funct7 = fields.get('funct7', '0000000')
        imm_val = fields.get('imm_val', 0)
        
        imm_bits = TYPE_MAP[instr_type_key]["imm_bits"]
        imm_bin = int_to_bin_signed(imm_val, imm_bits)

    except Exception as e:
        raise ValueError(f"Erro ao processar campos: {e}")

    bin_list = ['0'] * 32

    # 2. Montagem Base (Todos têm opcode em [6:0])
    bin_list[25:32] = list(opcode)

    # 3. Montagem Específica por Tipo
    if instr_type_str == "R":
        # Formato R: [funct7 | rs2 | rs1 | funct3 | rd | opcode]
        bin_list[0:7] = list(funct7)    # funct7 (31-25)
        bin_list[7:12] = list(rs2)      # rs2 (24-20)
        bin_list[12:17] = list(rs1)     # rs1 (19-15)
        bin_list[17:20] = list(funct3)  # funct3 (14-12)
        bin_list[20:25] = list(rd)      # rd (11-7)

    elif instr_type_str == "I":
        # Formato I: [imm[11:0] | rs1 | funct3 | rd | opcode]
        bin_list[0:12] = list(imm_bin)  # imm[11:0] (31-20)
        bin_list[12:17] = list(rs1)     # rs1 (19-15)
        bin_list[17:20] = list(funct3)  # funct3 (14-12)
        bin_list[20:25] = list(rd)      # rd (11-7)

    elif instr_type_str == "S":
        # Formato S: [imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode]
        bin_list[0:7] = list(imm_bin[0:7])    # imm[11:5] (31-25)
        bin_list[7:12] = list(rs2)            # rs2 (24-20)
        bin_list[12:17] = list(rs1)           # rs1 (19-15)
        bin_list[17:20] = list(funct3)        # funct3 (14-12)
        bin_list[20:25] = list(imm_bin[7:12]) # imm[4:0] (11-7)

    elif instr_type_str == "B":
        # Formato B: [imm[12] | imm[10:5] | rs2 | rs1 | funct3 | imm[4:1] | imm[11] | opcode]
        # imm_bin (13 bits): [12 | 11 | 10 | 9 | 8 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0]
        # Indices:           [0  | 1  | 2  | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12]
        bin_list[0] = imm_bin[0]              # imm[12] (31)
        bin_list[1:7] = list(imm_bin[2:8])    # imm[10:5] (30-25)
        bin_list[7:12] = list(rs2)            # rs2 (24-20)
        bin_list[12:17] = list(rs1)           # rs1 (19-15)
        bin_list[17:20] = list(funct3)        # funct3 (14-12)
        bin_list[20:24] = list(imm_bin[9:13]) # imm[4:1] (11-8)
        bin_list[24] = imm_bin[1]             # imm[11] (7)

    elif instr_type_str == "U":
        # Formato U: [imm[31:12] | rd | opcode]
        bin_list[0:20] = list(imm_bin)      # imm[31:12] (31-12)
        bin_list[20:25] = list(rd)          # rd (11-7)

    elif instr_type_str == "J":
        # Formato J: [imm[20] | imm[10:1] | imm[11] | imm[19:12] | rd | opcode]
        # imm_bin (21 bits): [20 | 19:12 | 11 | 10:1 | 0] -> Simplesmente para indexação.
        # Indices:           [0  | 1:9   | 9  | 10:19 | 20]
        bin_list[0] = imm_bin[0]              # imm[20] (31)
        bin_list[1:11] = list(imm_bin[10:20]) # imm[10:1] (30-21)
        bin_list[11] = imm_bin[9]             # imm[11] (20)
        bin_list[12:20] = list(imm_bin[1:9])  # imm[19:12] (19-12)
        bin_list[20:25] = list(rd)            # rd (11-7)

    return "".join(bin_list)


# --- 4. Interface Gráfica (Tkinter) ---

class RV32ITypeGenerator(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Gerador de Binários RV32I por Tipo")
        self.geometry("650x550")
        self.type_var = tk.StringVar(self)
        self.vars = {} # Dicionário para armazenar todas as StringVar

        self.create_widgets()

    def create_widgets(self):
        main_frame = ttk.Frame(self, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))

        # 1. Seleção do Tipo de Instrução
        ttk.Label(main_frame, text="Tipo de Instrução:").grid(row=0, column=0, sticky=tk.W, pady=5)
        types = list(TYPE_MAP.keys())
        self.type_combo = ttk.Combobox(main_frame, textvariable=self.type_var, values=types, width=15)
        self.type_combo.grid(row=0, column=1, sticky=tk.W, padx=5, pady=5)
        self.type_combo.bind("<<ComboboxSelected>>", self.update_fields_visibility)

        # Frame Dinâmico para Campos (onde rs1, rs2, opcode, etc., serão inseridos)
        self.fields_frame = ttk.Frame(main_frame, padding="10")
        self.fields_frame.grid(row=1, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=10)
        
        self.create_dynamic_fields()

        ttk.Button(main_frame, text="Gerar Binário", command=self.generate).grid(row=2, column=0, columnspan=3, pady=10)

        # 3. Resultados
        ttk.Label(main_frame, text="Binário (32 bits):").grid(row=3, column=0, sticky=tk.W, pady=5)
        self.result_bin = ttk.Label(main_frame, text="", foreground="blue", wraplength=500, font=("Courier", 10))
        self.result_bin.grid(row=3, column=1, columnspan=2, sticky=tk.W, padx=5, pady=5)

        ttk.Label(main_frame, text="Hexadecimal:").grid(row=4, column=0, sticky=tk.W, pady=5)
        self.result_hex = ttk.Label(main_frame, text="", foreground="green", font=("Courier", 12))
        self.result_hex.grid(row=4, column=1, columnspan=2, sticky=tk.W, padx=5, pady=5)
        
        self.type_var.set(types[0]) # Define o primeiro tipo como padrão
        self.update_fields_visibility()

    def create_dynamic_fields(self):
        """Cria todos os campos possíveis, mas esconde-os até serem necessários."""
        all_fields = ["opcode", "funct3", "funct7", "rs1", "rs2", "rd", "imm_val"]
        
        for i, field in enumerate(all_fields):
            label = ttk.Label(self.fields_frame, text=f"{field.upper()}:")
            label.grid(row=i, column=0, sticky=tk.W, pady=2)
            
            # Inicializa a variável e o widget de entrada
            self.vars[field] = tk.StringVar(self.fields_frame)
            entry = ttk.Entry(self.fields_frame, textvariable=self.vars[field], width=20)
            entry.grid(row=i, column=1, sticky=tk.W, padx=5, pady=2)

            # Armazena os widgets para controle de visibilidade
            self.vars[field + '_widget'] = [label, entry]

            # Define valores iniciais para facilitar a entrada
            if field == "opcode": self.vars[field].set("0110011") # Tipo R padrão
            if field == "funct3": self.vars[field].set("000")
            if field == "funct7": self.vars[field].set("0000000")
            if field in ["rs1", "rs2", "rd"]: self.vars[field].set("00001") # x1
            if field == "imm_val": self.vars[field].set("0") # Valor Imediato (decimal)
            
            # Inicialmente, esconde todos
            label.grid_forget()
            entry.grid_forget()

    def update_fields_visibility(self, event=None):
        """Mostra/esconde campos baseados no tipo selecionado."""
        selected_type = self.type_var.get()
        required_fields = TYPE_MAP.get(selected_type, {"fields":[]})["fields"]

        # 1. Esconder todos os campos
        for widget_list in self.vars.values():
            if isinstance(widget_list, list):
                for widget in widget_list:
                    widget.grid_forget()

        # 2. Mostrar apenas os campos requeridos
        row_idx = 0
        for field in required_fields:
            if field == "imm":
                # Campo Imediato (valor decimal)
                label, entry = self.vars['imm_val_widget']
                label.config(text=f"IMEDIATO (Dec, {TYPE_MAP[selected_type]['imm_bits']} bits):")
                label.grid(row=row_idx, column=0, sticky=tk.W, pady=2)
                entry.grid(row=row_idx, column=1, sticky=tk.W, padx=5, pady=2)
            else:
                # Campos de bits (opcode, funct) ou Registradores (rs1, rs2, rd)
                label, entry = self.vars[field + '_widget']
                
                # Exibe o número de bits esperado para campos de bits
                bit_size = get_field_bits(field)
                if bit_size > 0:
                     label.config(text=f"{field.upper()} ({bit_size} bits):")
                else:
                     label.config(text=f"{field.upper()}:")
                     
                label.grid(row=row_idx, column=0, sticky=tk.W, pady=2)
                entry.grid(row=row_idx, column=1, sticky=tk.W, padx=5, pady=2)
            
            row_idx += 1


    def generate(self):
        """Reúne os dados da interface e chama o gerador."""
        instr_type_key = self.type_var.get()
        fields_data = {}
        
        try:
            # Coleta os dados de todos os campos que têm uma variável de controle
            required_fields = TYPE_MAP[instr_type_key]["fields"]

            for field in required_fields:
                if field == "imm":
                    # Imediato é lido como inteiro
                    fields_data['imm_val'] = int(self.vars['imm_val'].get())
                elif field == "imm_val":
                    # Ignorar, pois 'imm' já cuida disso
                    continue 
                elif field in ["rs1", "rs2", "rd"]:
                    # Registradores são lidos como binário de 5 bits (ex: '00001')
                    reg_value = int(self.vars[field].get(), 2)
                    fields_data[field] = int_to_bin_signed(reg_value, 5)
                else:
                    # Opcode, funct3/7 são lidos como binário (string)
                    fields_data[field] = self.vars[field].get()
                    
                    # Validação de tamanho básico (Opcode 7, funct3 3, funct7 7)
                    bit_size = get_field_bits(field)
                    if bit_size > 0 and len(fields_data[field]) != bit_size:
                        raise ValueError(f"O campo {field.upper()} deve ter {bit_size} bits.")

            # Geração do binário
            binary_result = generate_binary_by_type(instr_type_key, fields_data)
            
            # Conversão para hexadecimal
            hex_result = hex(int(binary_result, 2))[2:].zfill(8)
            
            self.result_bin.config(text=binary_result)
            self.result_hex.config(text=f"0x{hex_result.upper()}")

        except ValueError as e:
            messagebox.showerror("Erro de Entrada", f"Verifique a entrada de bits/decimal.\nErro: {e}")
        except Exception as e:
            messagebox.showerror("Erro", f"Ocorreu um erro na geração do binário: {e}")


if __name__ == "__main__":
    app = RV32ITypeGenerator()
    app.mainloop()