PGDMP                      }            food_ordering_dev     16.4 (Ubuntu 16.4-1.pgdg22.04+2)     16.4 (Ubuntu 16.4-1.pgdg22.04+2) @    O           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            P           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            Q           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            R           1262    123084    food_ordering_dev    DATABASE     y   CREATE DATABASE food_ordering_dev WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';
 !   DROP DATABASE food_ordering_dev;
                postgres    false            �            1259    131277    drinks    TABLE     �   CREATE TABLE public.drinks (
    id bigint NOT NULL,
    name character varying(255),
    price numeric,
    slug character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);
    DROP TABLE public.drinks;
       public         heap    postgres    false            �            1259    131276    drinks_id_seq    SEQUENCE     v   CREATE SEQUENCE public.drinks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.drinks_id_seq;
       public          postgres    false    229            S           0    0    drinks_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.drinks_id_seq OWNED BY public.drinks.id;
          public          postgres    false    228            �            1259    123109    food_ingredients    TABLE     �   CREATE TABLE public.food_ingredients (
    id bigint NOT NULL,
    food_id bigint,
    ingredient_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);
 $   DROP TABLE public.food_ingredients;
       public         heap    postgres    false            �            1259    123108    food_ingredients_id_seq    SEQUENCE     �   CREATE SEQUENCE public.food_ingredients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.food_ingredients_id_seq;
       public          postgres    false    221            T           0    0    food_ingredients_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.food_ingredients_id_seq OWNED BY public.food_ingredients.id;
          public          postgres    false    220            �            1259    123158 
   food_menus    TABLE     �   CREATE TABLE public.food_menus (
    id bigint NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);
    DROP TABLE public.food_menus;
       public         heap    postgres    false            �            1259    123157    food_menus_id_seq    SEQUENCE     z   CREATE SEQUENCE public.food_menus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.food_menus_id_seq;
       public          postgres    false    227            U           0    0    food_menus_id_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.food_menus_id_seq OWNED BY public.food_menus.id;
          public          postgres    false    226            �            1259    123091    foods    TABLE     J  CREATE TABLE public.foods (
    id bigint NOT NULL,
    name character varying(255),
    price numeric,
    description text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    slug character varying(255),
    calories numeric,
    audio character varying(255)
);
    DROP TABLE public.foods;
       public         heap    postgres    false            �            1259    123090    foods_id_seq    SEQUENCE     u   CREATE SEQUENCE public.foods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.foods_id_seq;
       public          postgres    false    217            V           0    0    foods_id_seq    SEQUENCE OWNED BY     =   ALTER SEQUENCE public.foods_id_seq OWNED BY public.foods.id;
          public          postgres    false    216            �            1259    123100    ingredients    TABLE       CREATE TABLE public.ingredients (
    id bigint NOT NULL,
    name character varying(255),
    additional_price numeric,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    slug character varying(255)
);
    DROP TABLE public.ingredients;
       public         heap    postgres    false            �            1259    123099    ingredients_id_seq    SEQUENCE     {   CREATE SEQUENCE public.ingredients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.ingredients_id_seq;
       public          postgres    false    219            W           0    0    ingredients_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.ingredients_id_seq OWNED BY public.ingredients.id;
          public          postgres    false    218            �            1259    123137    order_items    TABLE     �   CREATE TABLE public.order_items (
    id bigint NOT NULL,
    customizations jsonb,
    order_id bigint,
    food_id bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);
    DROP TABLE public.order_items;
       public         heap    postgres    false            �            1259    123136    order_items_id_seq    SEQUENCE     {   CREATE SEQUENCE public.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.order_items_id_seq;
       public          postgres    false    225            X           0    0    order_items_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;
          public          postgres    false    224            �            1259    123128    orders    TABLE     �   CREATE TABLE public.orders (
    id bigint NOT NULL,
    order_number integer,
    total_price numeric,
    status character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);
    DROP TABLE public.orders;
       public         heap    postgres    false            �            1259    123127    orders_id_seq    SEQUENCE     v   CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.orders_id_seq;
       public          postgres    false    223            Y           0    0    orders_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;
          public          postgres    false    222            �            1259    123085    schema_migrations    TABLE     w   CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);
 %   DROP TABLE public.schema_migrations;
       public         heap    postgres    false            �           2604    131280 	   drinks id    DEFAULT     f   ALTER TABLE ONLY public.drinks ALTER COLUMN id SET DEFAULT nextval('public.drinks_id_seq'::regclass);
 8   ALTER TABLE public.drinks ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    229    228    229            �           2604    123112    food_ingredients id    DEFAULT     z   ALTER TABLE ONLY public.food_ingredients ALTER COLUMN id SET DEFAULT nextval('public.food_ingredients_id_seq'::regclass);
 B   ALTER TABLE public.food_ingredients ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    221    220    221            �           2604    123161    food_menus id    DEFAULT     n   ALTER TABLE ONLY public.food_menus ALTER COLUMN id SET DEFAULT nextval('public.food_menus_id_seq'::regclass);
 <   ALTER TABLE public.food_menus ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    227    226    227            �           2604    123094    foods id    DEFAULT     d   ALTER TABLE ONLY public.foods ALTER COLUMN id SET DEFAULT nextval('public.foods_id_seq'::regclass);
 7   ALTER TABLE public.foods ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    217    217            �           2604    123103    ingredients id    DEFAULT     p   ALTER TABLE ONLY public.ingredients ALTER COLUMN id SET DEFAULT nextval('public.ingredients_id_seq'::regclass);
 =   ALTER TABLE public.ingredients ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    219    218    219            �           2604    123140    order_items id    DEFAULT     p   ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);
 =   ALTER TABLE public.order_items ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    224    225    225            �           2604    123131 	   orders id    DEFAULT     f   ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);
 8   ALTER TABLE public.orders ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    222    223    223            L          0    131277    drinks 
   TABLE DATA           P   COPY public.drinks (id, name, price, slug, inserted_at, updated_at) FROM stdin;
    public          postgres    false    229   �I       D          0    123109    food_ingredients 
   TABLE DATA           _   COPY public.food_ingredients (id, food_id, ingredient_id, inserted_at, updated_at) FROM stdin;
    public          postgres    false    221   �J       J          0    123158 
   food_menus 
   TABLE DATA           A   COPY public.food_menus (id, inserted_at, updated_at) FROM stdin;
    public          postgres    false    227   K       @          0    123091    foods 
   TABLE DATA           m   COPY public.foods (id, name, price, description, inserted_at, updated_at, slug, calories, audio) FROM stdin;
    public          postgres    false    217   (K       B          0    123100    ingredients 
   TABLE DATA           `   COPY public.ingredients (id, name, additional_price, inserted_at, updated_at, slug) FROM stdin;
    public          postgres    false    219   |L       H          0    123137    order_items 
   TABLE DATA           e   COPY public.order_items (id, customizations, order_id, food_id, inserted_at, updated_at) FROM stdin;
    public          postgres    false    225   RM       F          0    123128    orders 
   TABLE DATA           `   COPY public.orders (id, order_number, total_price, status, inserted_at, updated_at) FROM stdin;
    public          postgres    false    223   hO       >          0    123085    schema_migrations 
   TABLE DATA           A   COPY public.schema_migrations (version, inserted_at) FROM stdin;
    public          postgres    false    215   �P       Z           0    0    drinks_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.drinks_id_seq', 7, true);
          public          postgres    false    228            [           0    0    food_ingredients_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.food_ingredients_id_seq', 34, true);
          public          postgres    false    220            \           0    0    food_menus_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.food_menus_id_seq', 1, false);
          public          postgres    false    226            ]           0    0    foods_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.foods_id_seq', 11, true);
          public          postgres    false    216            ^           0    0    ingredients_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.ingredients_id_seq', 20, true);
          public          postgres    false    218            _           0    0    order_items_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.order_items_id_seq', 134, true);
          public          postgres    false    224            `           0    0    orders_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.orders_id_seq', 114, true);
          public          postgres    false    222            �           2606    131284    drinks drinks_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.drinks
    ADD CONSTRAINT drinks_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.drinks DROP CONSTRAINT drinks_pkey;
       public            postgres    false    229            �           2606    123114 &   food_ingredients food_ingredients_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.food_ingredients
    ADD CONSTRAINT food_ingredients_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.food_ingredients DROP CONSTRAINT food_ingredients_pkey;
       public            postgres    false    221            �           2606    123163    food_menus food_menus_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.food_menus
    ADD CONSTRAINT food_menus_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.food_menus DROP CONSTRAINT food_menus_pkey;
       public            postgres    false    227            �           2606    123098    foods foods_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.foods
    ADD CONSTRAINT foods_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.foods DROP CONSTRAINT foods_pkey;
       public            postgres    false    217            �           2606    123107    ingredients ingredients_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.ingredients
    ADD CONSTRAINT ingredients_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.ingredients DROP CONSTRAINT ingredients_pkey;
       public            postgres    false    219            �           2606    123144    order_items order_items_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.order_items DROP CONSTRAINT order_items_pkey;
       public            postgres    false    225            �           2606    123135    orders orders_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.orders DROP CONSTRAINT orders_pkey;
       public            postgres    false    223            �           2606    123089 (   schema_migrations schema_migrations_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);
 R   ALTER TABLE ONLY public.schema_migrations DROP CONSTRAINT schema_migrations_pkey;
       public            postgres    false    215            �           1259    123125    food_ingredients_food_id_index    INDEX     ^   CREATE INDEX food_ingredients_food_id_index ON public.food_ingredients USING btree (food_id);
 2   DROP INDEX public.food_ingredients_food_id_index;
       public            postgres    false    221            �           1259    123126 $   food_ingredients_ingredient_id_index    INDEX     j   CREATE INDEX food_ingredients_ingredient_id_index ON public.food_ingredients USING btree (ingredient_id);
 8   DROP INDEX public.food_ingredients_ingredient_id_index;
       public            postgres    false    221            �           1259    123156    order_items_food_id_index    INDEX     T   CREATE INDEX order_items_food_id_index ON public.order_items USING btree (food_id);
 -   DROP INDEX public.order_items_food_id_index;
       public            postgres    false    225            �           1259    123155    order_items_order_id_index    INDEX     V   CREATE INDEX order_items_order_id_index ON public.order_items USING btree (order_id);
 .   DROP INDEX public.order_items_order_id_index;
       public            postgres    false    225            �           2606    123115 .   food_ingredients food_ingredients_food_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.food_ingredients
    ADD CONSTRAINT food_ingredients_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(id);
 X   ALTER TABLE ONLY public.food_ingredients DROP CONSTRAINT food_ingredients_food_id_fkey;
       public          postgres    false    221    3226    217            �           2606    123120 4   food_ingredients food_ingredients_ingredient_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.food_ingredients
    ADD CONSTRAINT food_ingredients_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id);
 ^   ALTER TABLE ONLY public.food_ingredients DROP CONSTRAINT food_ingredients_ingredient_id_fkey;
       public          postgres    false    221    219    3228            �           2606    123150 $   order_items order_items_food_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(id);
 N   ALTER TABLE ONLY public.order_items DROP CONSTRAINT order_items_food_id_fkey;
       public          postgres    false    3226    225    217            �           2606    123145 %   order_items order_items_order_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);
 O   ALTER TABLE ONLY public.order_items DROP CONSTRAINT order_items_order_id_fkey;
       public          postgres    false    3234    223    225            L   �   x�3400��,��4�, SF��F��
�FV�&V�F�ĸ9����A$�ڌ8�3��+t��s9��L9�A�`��se&�)$�怜����&�b�	���#�H&��%� SΣ���A&@h���q��$rZp�ib���qqq �<g      D   _   x��ͱ�0����!abǳd�9r�.p+=��!p�1���]�"W�]�d�^��>꾧G�Gz���~���H?��!S��=%�׽�h�����w��i�^�      J      x������ � �      @   D  x��QAN�0<;����N�ZqC@ �W.K�V'��89�}D?©�v���r��j�;+��o52�s��:�P'�G��q���x��@�l\_ws���[�Y�F4h�.x4O�Chm��o���TY���b�� �]Q��՟Z=��<&�p�f�n=�u�b(�:��at�!�*"���T9��q�� ;��4A\j��lp�K�:��0��I&{��P��ݠ�NŤd/gr��e]��"y�]I A�+;0�6��t��l�҇D�*�M�"�t"�'+��L.���qoT�A݃��[���4���f�}�Y�� �g��      B   �   x���K
�@��ur�^�2�:T����E(i��U7=�^�U��3�K�6�%��R�Vl9�2<h��L�,Q�J�I��2�
FZ��˨��S�O
AJ`xH~/���ߺ	��R^(��r���Tj��M�7>	Y�d��H;��x~��u��0��1$=�e|Fhϐ���9ۀօlQ+W���҇T�&��?���2      H     x�͗IN�0���)���y��+ k��Q-����� n WbU��s(j�_�&�R)����ϛ� ��sr�`�Y9{LtqRV7S�/m5�G�"9���M������㑙'�ޚ����h�iڷ�7�\��
��z�qu��!�bZ�Z*J� �A89vKO��ƕ}���-8�'���`��ESJC�h��
A
�"5�Π4��Ra�j9�3'�8R3��!'휡"�p\VPr���S�	�ʻ� c�R���)IE3i�j��:v}g�����U9lh���(���x�v�p^��Z�~�Z|��Ӝ2-8��io\��r-�Rb�R�����N�q_hƵ$5t�y::P��y::��|�I�|��T*�C�eKih:ݏ�K� ��y��t�)3���h���h�u$N���5$��]o%-���(4g��aQd���YQdaQ-$���-v�]��C�R��~����d�.B�J� �N�R�b�^4E]{�W�4pJ��e�@�8,�I�ay�� c7Q�0����(��O�W�      F     x�}�A��0E��)z�F�!6����fS��W�u�B$��x��fM�f�������iBbw�;���j���F�hF�C�6�3�d�'��Z�a����*D"��u�6�����u����a8+cP�yi��{�/S�Bϲ!�:pU�Q��XC���;�xF$�3cp�p��\�M��1�;5K�9de�<n[������1�4��ݓ���_�kA��	yc+��3X2������5�T���Ϫ����h|5^��T�x%Ke��;�����z��r���      >   p   x����1�o:�-Pd;���,��t��C%�XzJdA;���n��]�F�g�������ɾ&�r����H��"��� ��4��ꈍV��}HRx('����l罵�z';I     